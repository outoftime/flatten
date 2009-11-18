module Flatten
  class Document < Resource
    attr_reader :id

    def initialize(data)
      super
      @id = data[:id]
    end
  end

  class <<Document
    private :new

    def get(id)
      from_data(Flatten.adapter.read(self.name, id))
    end

    def flatten(model)
      data = to_data(model)
      data.merge!(:id => model.id)
      alternate_ids = alternate_id_fields.inject({}) do |hash, field|
        if id_value = model.send(field)
          hash.merge!(field.to_sym => id_value) 
        end
        hash
      end
      Flatten.adapter.write(self.name, model.id, alternate_ids, data)
      model
    end

    def update(model, *properties)
      if properties.empty?
        flatten(model)
      else
        data = Flatten.adapter.read(self.name, model.id)
        properties.each do |property|
          update_data(data, model, property)
        end
        Flatten.adapter.write(self.name, model.id, {}, data)
      end
    end

    def delete(model)
      Flatten.adapter.delete(self.name, model.id)
    end

    def alternate_id(*fields)
      alternate_id_fields.concat(fields)
      fields.each do |field|
        instance_eval(<<-RUBY, __FILE__, __LINE__ + 1)
          def get_by_#{field}(name)
            from_data(
              Flatten.adapter.read_from(
                #{self.name.inspect},
                #{field.to_sym.inspect},
                name
              )
            )
          end
        RUBY
      end
    end

    def alternate_id_fields
      @alternate_id_fields ||= []
    end
  end
end
