require File.join(File.dirname(__FILE__), 'spec_helper')

describe Flatten do
  before :each do
    @post = Post.new do |post|
      post.title = 'Test Title'
      post.category_ids.concat([1, 3, 5])
      post.blog = Blog.new do |blog|
        blog.name = 'Test Blog'
      end
      post.comments << Comment.new { |comment| comment.text = 'First comment' }
      post.comments << Comment.new { |comment| comment.text = 'Second comment' }
      post.photos << Photo.new { |photo| photo.path = '/000/000/001/1.jpg' }
    end
    FlatPost.flatten(@post)
    @id = @post.id
  end

  it 'should save and retrieve scalar properties' do
    post = FlatPost.get(@id)
    post.title.should == 'Test Title'
  end

  it 'should retrieve scalar objects multiple times' do
    post = FlatPost.get(@id)
    post.title
    post.title.should == 'Test Title'
  end

  it 'should return nil for nil properties' do
    post = FlatPost.get(@id)
    post.body.should be_nil
  end

  it 'should save and retrieve arrays of scalars' do
    post = FlatPost.get(@id)
    post.category_ids.should == [1, 3, 5]
  end

  it 'should embed associated objects' do
    post = FlatPost.get(@id)
    post.blog.name.should == 'Test Blog'
  end

  it 'should embed associated objects using externally defined resource' do
    FlatPost.get(@id).featured_photo.path.should == '/000/000/001/1.jpg'
  end

  it 'should raise an ArgumentError if no block or :using is passed for embed' do
    lambda do
      FlatPost.module_eval do
        embed :bogus
      end
    end.should raise_error(ArgumentError)
  end

  it 'should return nil for nil associated objects' do
    FlatPost.flatten(Post.new { |post| @id = post.id })
    post = FlatPost.get(@id)
    post.blog.should be_nil
  end

  it 'should embed associated collections' do
    post = FlatPost.get(@id)
    ['First comment', 'Second comment'].each_with_index do |text, i|
      post.comments[i].text.should == text
    end
  end

  it 'should not allow modification to collections' do
    post = FlatPost.get(@id)
    comments = post.comments
    lambda { comments << post.comments.first }.should raise_error
    lambda { comments.clear }.should raise_error
    lambda { comments.push }.should raise_error
    lambda { comments.pop }.should raise_error
    lambda { comments.unshift }.should raise_error
    lambda { comments.shift }.should raise_error
  end

  it 'should embed collections using externally defined resource' do
    post = FlatPost.get(@id)
    post.photos.first.path.should == '/000/000/001/1.jpg'
  end

  it 'should raise an ArgumentError if no block or :using is passed for embed_collection' do
    lambda do
      FlatPost.module_eval do
        embed_collection :bogus
      end
    end.should raise_error(ArgumentError)
  end

  it 'should retrieve objects using alternate identifiers' do
    post = FlatPost.get_by_permalink('test-title')
    post.title.should == 'Test Title'
  end

  it 'should do partial update of property' do
    @post.title = 'New Title'
    %w(body category_ids blog comments photos featured_photo).each do |method|
      @post.should_not_receive method
    end
    FlatPost.update(@post, :title)
    FlatPost.get(@id).title.should == 'New Title'
  end

  it 'should do partial update of embedded property' do
    @post.featured_photo.path = '1.jpg'
    %w(title body category_ids blog comments).each do |method|
      @post.should_not_receive method
    end
    @post.featured_photo.should_not_receive :caption
    FlatPost.update(@post, :featured_photo => :path)
    FlatPost.get(@id).featured_photo.path.should == '1.jpg'
  end

  it 'should do a partial update of two embedded properties' do
    @post.featured_photo.path = '1.jpg'
    @post.featured_photo.caption = 'Having fun!'
    %w(title body category_ids blog comments).each do |method|
      @post.should_not_receive method
    end
    FlatPost.update(@post, :featured_photo => [:path, :caption])
    FlatPost.get(@id).featured_photo.path.should == '1.jpg'
    FlatPost.get(@id).featured_photo.caption.should == 'Having fun!'
  end

  it 'should do a partial update of an entire embedded resource' do
    @post.featured_photo.path = '1.jpg'
    @post.featured_photo.caption = 'Having fun!'
    %w(title body category_ids blog comments).each do |method|
      @post.should_not_receive method
    end
    FlatPost.update(@post, :featured_photo)
    FlatPost.get(@id).featured_photo.path.should == '1.jpg'
    FlatPost.get(@id).featured_photo.caption.should == 'Having fun!'
  end

  it 'should raise an ArgumentError if a partial update is attempted against a property of an embedded collection' do
    lambda do
      FlatPost.update(@post, :photos => :path)
    end.should raise_error(ArgumentError)
  end

  it 'should perform partial update on entire embedded collection' do
    @post.photos.first.path = '1.jpg'
    @post.photos.first.caption = 'Having fun!'
    %w(title body category_ids blog comments featured_photo).each do |method|
      @post.should_not_receive method
    end
    FlatPost.update(@post, :photos)
    FlatPost.get(@id).photos.first.path.should == '1.jpg'
    FlatPost.get(@id).photos.first.caption.should == 'Having fun!'
  end

  it 'should perform full update if no properties given for partial update' do
    @post.title = 'Different Title'
    @post.blog = Blog.new do |blog|
      blog.name = 'Different Blog'
    end
    FlatPost.update(@post)
    FlatPost.get(@id).title.should == 'Different Title'
    FlatPost.get(@id).blog.name.should == 'Different Blog'
  end

  it 'should delete flattened objects' do
    FlatPost.delete(@post)
    FlatPost.get(@id).should be_nil
  end
end
