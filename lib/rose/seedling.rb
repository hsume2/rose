require 'rose/proxy'

module Rose
  # Defines the Rose DSL
  class Seedling
    # @return [Rose::Proxy::Row] the row proxy containing an array of Attributes
    attr_reader :row

    # @return [Rose::Proxy::Root] the root proxy containing attribute finder and updater
    attr_reader :root

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

    # @yield Proxy::Row
    def rows(&blk)
      proxy = Proxy::Row.new
      proxy.instance_eval(&blk)
      @row = proxy
    end

    # @param [String, Symbol] column_name the column to sort by
    # @param [:ascending, :descending] order the order to sort by
    def sort(column_name, order = :ascending, &sort_block)
      @options[:sort] = Attribute::Sort.new(column_name, order, &sort_block)
      @alterations << @options[:sort]
    end

    # @yield Rose::Attribute::Filter
    def filter(&filter_block)
      @options[:filter] = Attribute::Filter.new(nil, nil, filter_block)
      @alterations << @options[:filter]
    end

    # @param [String, Symbol] column_name the column to group by
    # @yield Proxy::Summary
    def summary(column_name, &blk)
      proxy = Proxy::Summary.new(column_name)
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

    # @yield Proxy::Root
    def roots(&blk)
      proxy = Proxy::Root.new
      proxy.instance_eval(&blk)
      @root = proxy
    end
  end
end