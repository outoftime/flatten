require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'Flatten Filters' do
  before :each do
    @post = Post.new do |post|
      post.comments << Comment.new { |comment| comment.text = 'First comment' }
      post.comments << Comment.new
    end
    FlatPost.flatten(@post)
    @id = @post.id
  end

  it 'should apply a filter to a collection' do
    FlatPost.get(@id).comments.with_text.should have(1).items
  end
end
