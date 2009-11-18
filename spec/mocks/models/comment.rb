class Comment
  attr_accessor :text

  def initialize
    yield(self) if block_given?
  end
end
