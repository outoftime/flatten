class Post
  @@id = 0

  attr_reader :id
  attr_accessor :title, :body, :blog

  def initialize
    @id = @@id += 1
    yield(self)
  end

  def category_ids
    @category_ids ||= []
  end

  def comments
    @comments ||= []
  end

  def permalink
    title.downcase.gsub(/\W+/, '-') if title
  end
end
