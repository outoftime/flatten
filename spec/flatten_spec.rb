require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'Flatten' do
  before :each do
    post = Post.new do |p|
      p.title = 'Test Title'
      p.category_ids.concat([1, 3, 5])
      p.blog = Blog.new do |b|
        b.name = 'Test Blog'
      end
      p.comments << Comment.new { |comment| comment.text = 'First comment' }
      p.comments << Comment.new { |comment| comment.text = 'Second comment' }
    end
    FlatPost.flatten(post)
    @id = post.id
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

  it 'should freeze collections before returning them' do
    post = FlatPost.get(@id)
    post.comments.should be_frozen
  end

  it 'should retrieve objects using alternate identifiers' do
    post = FlatPost.get_by_permalink('test-title')
    post.title.should == 'Test Title'
  end
end
