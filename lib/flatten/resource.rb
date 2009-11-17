module Flatten
  class Resource
    def initialize(data)
      @data = data
    end
  end

  class <<Resource
    def from_data(data)
      new(data) if data
    end

    def to_data(model)
      return unless model
      data = {}
      for property in properties
        data[property] = model.send(property)
      end
      embedded_resources.each_pair do |name, resource_class|
        data[name] = resource_class.to_data(model.send(name))
      end
      embedded_collections.each_pair do |name, resource_class|
        data[name] = (model.send(name) || []).map do |embedded_resource|
          resource_class.to_data(embedded_resource)
        end
      end
      data
    end

    def property(*names)
      properties.concat(names.map { |name| name.to_sym })
      for name in names
        properties << name.to_sym
        module_eval(<<-RUBY, __FILE__, __LINE__)
          def #{name}
            unless defined?(@#{name})
              @#{name} = @data[#{name.to_sym.inspect}]
            end
            @#{name}
          end
        RUBY
      end
    end

    def embed(name, options = {}, &block)
      resource_class =
        if block then Class.new(self, &block)
        elsif options[:using] then options[:using]
        else
          raise(
            ArgumentError,
            "Must provide either block or :using option to embed_collection"
          )
        end
      embedded_resources[name.to_sym] = resource_class
      module_eval(<<-RUBY, __FILE__, __LINE__)
        def #{name}
          unless defined?(@#{name})
            resource_class = self.class.embedded_resources[#{name.to_sym.inspect}]
            @#{name} = resource_class.from_data(@data[#{name.to_sym.inspect}])
          end
          @#{name}
        end
      RUBY
    end

    def embed_collection(name, options = {}, &block)
      resource_class =
        if block then Class.new(self, &block)
        elsif options[:using] then options[:using]
        else
          raise(
            ArgumentError,
            "Must provide either block or :using option to embed_collection"
          )
        end
      embedded_collections[name.to_sym] = resource_class
      module_eval(<<-RUBY, __FILE__, __LINE__)
      def #{name}
        unless defined?(@#{name})
          resource_class = self.class.embedded_collections[#{name.to_sym.inspect}]
          @#{name} = @data[#{name.to_sym.inspect}].map do |resource_data|
            resource_class.from_data(resource_data)
          end
          @#{name}.freeze
        end
        @#{name}
      end
      RUBY
    end

    def properties
      @properties ||= []
    end
    
    def embedded_resources
      @emedded_resources ||= {}
    end

    def embedded_collections
      @embedded_collections ||= {}
    end
  end
end
