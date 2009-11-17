class Photo
  attr_accessor :path
  attr_accessor :caption

  def initialize
    yield(self) if block_given?
  end
end
