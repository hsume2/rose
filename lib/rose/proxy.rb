require 'rose/attribute'

module Rose
  # This class is used during the DSL to collect a row of attributes
  class RowProxy
    attr_accessor :attributes

    def initialize
      @attributes = Attribute::Collection.new
    end

    def column(name, &blk)
      name, title = self.class.name_and_title(name)

      if block_given?
        attribute = Attribute::Indirect.new(name, title, blk)
      else
        attribute = Attribute::Direct.new(name, title)
      end

      @attributes << attribute
    end

    def self.name_and_title(name)
      case name
      when Hash
        name.to_a.first
      else
        [name, nil]
      end
    end
  end

  # This class is used during the DSL to collect summary attributes
  class SummaryProxy < RowProxy
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
      Table([@column_name] | @attributes.column_names).tap do |table|
        rows.each { |row| table << row }
      end
    end
  end
end