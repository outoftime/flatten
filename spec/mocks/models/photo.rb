class Photo
  attr_accessor :path
  attr_accessor :dimensions

  def initialize
    yield(self) if block_given?
  end
end
