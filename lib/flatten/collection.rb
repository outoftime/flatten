module Flatten
  class Collection
    class <<self
      def extend_for(resource_class)
        Class.new(self) do
          @resource_class = resource_class
          class <<self
            attr_reader :resource_class
          end

          resource_class.scopes.keys.each do |name|
            module_eval(<<-RUBY, __FILE__, __LINE__+1)
              def #{name}
                filtered_items = self.class.resource_class.scopes[#{name.to_sym.inspect}].call(items)
                filtered_collection = self.class.new
                filtered_collection.items = filtered_items
                filtered_collection
              end
            RUBY
          end
        end
      end
    end

    include Enumerable

    attr_writer :data
    attr_writer :items

    def initialize(data = nil)
      @data = data
    end

    def items
      @items ||= @data.map do |item|
        self.class.resource_class.from_data(item)
      end
    end

    def [](i)
      items[i]
    end

    def first
      items.first
    end

    def last
      items.last
    end

    def each(&block)
      items.each(&block)
    end

    def length
      items.length
    end
  end
end
