require 'rose'
require 'rose/ruport'

module Rose
  # This class is provides Objects the ability to run reports
  class ObjectAdapter
    # @param [Array<Rose::Attribute>] row_attributes the list of attributes that each cell in a row
    # @param [Array] items the items to report on
    # @param [Hash] options the options to run with
    # @option opts [String] :group_column
    # @option opts [String] :pivot_column
    # @option opts [String] :value_block
    # @option opts [String] :summary
    # @option opts [String] :summary_on
    # @option opts [String] :sort_by
    # @option opts [String] :sort_order
    # @return [Ruport::Data::Table] the resulting table
    def self.sprout(row_attributes, items=[], options={})
      table = Ruport::Data::RoseTable.new(:column_names => row_attributes.column_names)

      rows(table, items, row_attributes, options)

      if (alterations = options[:alterations])
        alterations.each do |alteration|
          table = alteration.on(table)
        end
      end

      table
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

  # module ObjectExtensions
  #   def self.included(base)
  #     base.extend(ClassMethods)
  #   end
  #
  #   module ClassMethods
  #
  #   end
  # end
end

# class Object
#   include Rose::ObjectExtensions
# end