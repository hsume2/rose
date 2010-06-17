require 'rose'
require 'rose/ruport'

module Rose
  # This class is provides Objects the ability to run reports
  class ObjectAdapter
    # @param [Array<Rose::Attribute>] row_attributes the list of attributes that each cell in a row
    # @param [Array] items the items to report on
    # @param [Hash] options the options to run with
    # @option options [String] :group_column (nil) @deprecated
    # @option options [String] :pivot_column (nil) @deprecated
    # @option options [String] :value_block (nil) @deprecated
    # @option options [String] :summary (nil) @deprecated
    # @option options [String] :summary_on (nil) @deprecated
    # @option options [String] :sort_by (nil) @deprecated
    # @option options [String] :sort_order (nil) @deprecated
    # @return [Ruport::Data::Table] the resulting table
    def self.sprout(row, items=[], options={})
      attributes = row.attributes
      table = Ruport::Data::RoseTable.new(:column_names => attributes.column_names)

      self.rows(table, items, attributes, options)

      if (alterations = options[:alterations])
        alterations.each do |alteration|
          table = alteration.on(table)
        end
      end

      table
    end

    def self.osmosis(root, updates={}, options={})
      root.updater.call(updates)
    end

    def self.rows(table, items, attributes, options={})
      items.each do |item|
        options[:class].tap { |enforce_class| enforce_item_type(item, enforce_class) if enforce_class }
        table << attributes.row { |attr| attr.evaluate(item).to_s }
      end
    end

    def self.enforce_item_type(item, klass)
      raise TypeError.new("Expected #{klass}, got #{item.class}") unless item.kind_of?(klass)
    end
  end
end
