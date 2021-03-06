module Flatten
  class Resource
    def initialize(data)
      @data = data
    end

    class <<self
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
          module_eval(<<-RUBY, __FILE__, __LINE__ + 1)
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
              collection_class = self.class.embedded_collections[#{name.to_sym.inspect}].collection_class
              @#{name} = collection_class.new(@data[#{name.to_sym.inspect}])
            end
            @#{name}
          end
        RUBY
      end

      def scope(name, &block)
        scopes[name.to_sym] = block
      end

      def collection_class
        @collection_class ||= Collection.extend_for(self)
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

      def scopes
        @scopes ||= {}
      end

      protected

      def update_data(data, model, property)
        if property.is_a?(Hash)
          property.each_pair do |embed, embedded_properties|
            if embedded_resources[embed.to_sym]
              Array(embedded_properties).each do |embedded_property|
                update_data(data[embed.to_sym], model.send(embed), embedded_property)
              end
            elsif embedded_collections[embed.to_sym]
              raise ArgumentError, "Can't do partial update on single property in embedded collection"
            end
          end
        elsif embedded_resources.has_key?(property.to_sym)
          resource = embedded_resources[property.to_sym]
          data[property.to_sym] = resource.to_data(model.send(property))
        elsif embedded_collections.has_key?(property.to_sym)
          resource = embedded_collections[property.to_sym]
          data[property.to_sym] = model.send(property).map do |value|
            resource.to_data(value)
          end
        else
          data[property.to_sym] = model.send(property)
        end
      end
    end
  end
end
