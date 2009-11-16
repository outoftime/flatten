class Comment
  attr_accessor :text

  def initialize
    yield(self)
  end
end
