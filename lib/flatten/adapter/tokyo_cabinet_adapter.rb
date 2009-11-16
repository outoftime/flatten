require 'tokyocabinet'
require File.join(File.dirname(__FILE__), 'abstract_tokyo_adapter')

module Flatten
  module Adapter
    class TokyoCabinetAdapter < AbstractTokyoAdapter
      def initialize(path)
        @database = TokyoCabinet::HDB.new
        database_try do
          @database.open(
            File.expand_path(path),
            TokyoCabinet::HDB::OWRITER | 
              TokyoCabinet::HDB::OREADER |
              TokyoCabinet::HDB::OCREAT
          )
        end
      end
    end
  end
end
