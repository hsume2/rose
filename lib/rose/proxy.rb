require 'rose/attribute'

module Rose
  module Proxy
    # This class is used by the DSL to collect a row of attributes
    class Row
      # Each attribute defines how values are generated for that column
      # as well how that column is named
      # @return [Rose::Attribute::Collection] A collection of attributes
      attr_reader :attributes

      # @return [Rose::Attribute] attribute used to determine which column
      #   is the id column
      attr_reader :identity_attribute

      def initialize
        @attributes = Attribute::Collection.new
      end

      def column(name, &blk)
        @attributes << attribute(name, &blk)
      end

      def identity(name, &blk)
        column(name, &blk)
        @identity_attribute = @attributes.last
      end

      def self.name_and_title(name)
        case name
        when Hash
          name.to_a.first
        else
          [name, nil]
        end
      end

      private

      def attribute(name, &blk)
        name, title = self.class.name_and_title(name)

        if block_given?
          attribute = Attribute::Indirect.new(name, title, blk)
        else
          attribute = Attribute::Direct.new(name, title)
        end
      end
    end

    # This class is used by the DSL to collect summary attributes
    class Summary < Row
      attr_reader :column_name

      def initialize(column_name)
        super()
        @column_name = column_name
      end

      def on(table)
        rows = table.column(@column_name).uniq.inject([]) do |rows, group|
          rows << @attributes.row { |attr|
            gr = table.grouped_rows({@column_name => group}, attr.column_name)
            attr.evaluate(gr)
          }.merge(@column_name => group)
        end
        Ruport::Data::RoseTable.new(:column_names => [@column_name] | @attributes.column_names).tap do |table|
          rows.each { |row| table << row }
        end
      end
    end

    # This class is used by the DSL to collect update attributes.
    # Just like a root is the foundation of transporting water into
    # a tree, a Root provides what's required to import data into a Rose
    class Root
      attr_reader :finder
      attr_reader :updater
      attr_reader :update_previewer
      attr_reader :creator
      attr_reader :create_previewer

      def find(&blk)
        @finder = blk
      end

      def update(&blk)
        @updater = blk
      end

      def preview_update(&blk)
        @update_previewer = blk
      end

      def create(&blk)
        @creator = blk
      end

      def preview_create(&blk)
        @create_previewer = blk
      end

      # @param [true, false] preview whether to use the update_previewer or not
      def updater(preview = false)
        preview ? @update_previewer : @updater
      end

      # @param [true, false] preview whether to use the create_previewer or not
      def creator(preview = false)
        preview ? @create_previewer : @creator
      end
    end
  end
end