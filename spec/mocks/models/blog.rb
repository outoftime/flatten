class Blog
  attr_accessor :name

  def initialize
    yield(self)
  end
end
