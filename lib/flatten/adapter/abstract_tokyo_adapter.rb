require 'tokyocabinet'

module Flatten
  module Adapter
    class AbstractTokyoAdapter
      def read(class_name, id)
        if data = @database.get(key(class_name, id))
          YAML.load(data)
        end
      end

      def read_from(class_name, alternate_id_field, alternate_id_value)
        alias_key = alias_key(class_name, alternate_id_field, alternate_id_value)
        if primary_key = @database.get(alias_key)
          if data = @database.get(primary_key)
            YAML.load(data)
          end
        end
      end

      def write(class_name, id, alternate_ids, data)
        database_try { @database.put(key(class_name, id), YAML.dump(data)) }
        alternate_ids.each_pair do |field_name, id_value|
          database_try do
            @database.put(
              alias_key(class_name, field_name, id_value),
              key(class_name, id)
            )
          end
        end
      end

      def delete(class_name, id)
        database_try { @database.out(key(class_name, id)) }
      end

      private

      def database_try
        unless yield
          raise AdapterError, @database.errmsg
        end
      end

      def key(class_name, id)
        "p#{class_name} #{id}"
      end

      def alias_key(class_name, alternate_id_field, alternate_id_value)
        "a#{class_name} #{alternate_id_field} #{alternate_id_value}"
      end
    end
  end
end
