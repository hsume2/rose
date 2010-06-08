require 'rose/proxy'

module Rose
  # Defines the Rose DSL
  class Seedling
    attr_reader :row
    attr_reader :adapter, :options, :alterations

    def initialize(adapter, options={})
      @adapter     = adapter
      @options     = options
      @alterations = @options[:alterations] = []
    end

    def rows(&blk)
      proxy = RowProxy.new
      proxy.instance_eval(&blk)
      @row = proxy
    end

    def sort(column_name, order = :ascending)
      @options[:sort] = Attribute::Sort.new(column_name, order)
      @alterations << @options[:sort]
    end

    def summary(column_name, &blk)
      proxy = SummaryProxy.new(column_name)
      proxy.instance_eval(&blk)
      @options[:summary] = proxy
      @alterations << @options[:summary]
    end

    def pivot(group_column, pivot_column, &blk)
      @options[:pivot] = Attribute::Pivot.new(group_column, pivot_column, blk)
      @alterations << @options[:pivot]
    end

    def bloom(items=[])
      @adapter.sprout(@row.attributes, items, @options)
    end
  end
end