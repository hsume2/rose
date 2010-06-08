require 'rose/proxy'

module Rose
  # Defines the Rose DSL
  class Seedling
    # @return [RowProxy] the row proxy containing an array of Attributes
    attr_reader :row

    # @return [ObjectAdapter] the adapter
    attr_reader :adapter

    # @return [Hash] the options used by the adapter
    attr_reader :options

    # @return [Array] the alterations to be applied to the sprouted Seedling (the report)
    attr_reader :alterations

    # @param [ObjectAdapter] adapter An ObjectAdapter capable of sprouting a Seedling 
    #   (running the report)
    # @param [Hash] options 
    # @option options [Class] :class (nil) Used during by the adapter to enforce items types
    def initialize(adapter, options={})
      @adapter     = adapter
      @options     = options
      @alterations = @options[:alterations] = []
    end

    # @yield RowProxy
    def rows(&blk)
      proxy = RowProxy.new
      proxy.instance_eval(&blk)
      @row = proxy
    end

    # @param [String, Symbol] column_name the column to sort by
    # @param [:ascending, :descending] order the order to sort by
    def sort(column_name, order = :ascending)
      @options[:sort] = Attribute::Sort.new(column_name, order)
      @alterations << @options[:sort]
    end

    # @param [String, Symbol] column_name the column to group by
    # @yield SummaryProxy
    def summary(column_name, &blk)
      proxy = SummaryProxy.new(column_name)
      proxy.instance_eval(&blk)
      @options[:summary] = proxy
      @alterations << @options[:summary]
    end

    # @param [String, Symbol] group_column the column to use for row data
    # @param [String, Symbol] pivot_column the column to use for column data
    # @param [Proc] value_block the block used to evalue the value data
    def pivot(group_column, pivot_column, &value_block)
      @options[:pivot] = Attribute::Pivot.new(group_column, pivot_column, value_block)
      @alterations << @options[:pivot]
    end

    # @param [Array] items the items to sprout the seedling with (run the report with)
    # @return [Ruport::Data::RoseTable] the resulting table
    def bloom(items=[])
      @adapter.sprout(@row.attributes, items, @options)
    end
  end
end