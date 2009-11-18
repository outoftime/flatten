require 'fileutils'

module Flatten
  module Adapter
    class FileAdapter
      def initialize(base_dir)
        @base_dir = base_dir
      end

      def read(class_name, id)
        filename = filename(class_name, id)
        if File.exist?(filename)
          File.open(filename, 'r') do |file|
            YAML.load(file)
          end
        end
      end

      def read_from(class_name, alternate_id_field, alternate_id_value)
        File.open(File.join(class_dir(class_name), alternate_id_field.to_s, "#{alternate_id_value}.yml"), 'r') do |file|
          YAML.load(file)
        end
      end

      def write(class_name, id, alternate_ids, data)
        filename = filename(class_name, id)
        File.open(filename, 'w') do |file|
          YAML.dump(data, file)
        end
        alternate_ids.each_pair do |field_name, id_value|
          alternate_dir = File.expand_path(File.join(class_dir(class_name), field_name.to_s))
          FileUtils.mkdir_p(alternate_dir)
          alternate_filename = File.join(alternate_dir, "#{id_value}.yml")
          FileUtils.rm_f(alternate_filename) if File.exists?(alternate_filename)
          FileUtils.ln_s(File.expand_path(filename), alternate_filename)
        end
      end

      def delete(class_name, id)
        filename = filename(class_name, id)
        FileUtils.rm_f(filename) if File.exists?(filename)
      end

      private

      def filename(class_name, id)
        dir = class_dir(class_name)
        FileUtils.mkdir_p(dir)
        File.join(dir, "#{id.to_s}.yml")
      end

      def class_dir(class_name)
        File.join(@base_dir, class_name.split('::'))
      end
    end
  end
end
