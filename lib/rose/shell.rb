module Rose
  # This class is a wrapper around Seedling that provides methods
  # we don't want invoked within the Rose#make DSL.
  #
  # A seedling with a shell is still a seedling. Hence, it should
  # be have as such!
  class Shell
    # @return [Rose::Seedling] the current seedling
    attr_reader :seedling

    def initialize(seedling)
      @seedling = seedling
    end

    # Provides bulk exporting
    # @param [Array] items the items to sprout the seedling with
    # @return [Ruport::Data::RoseTable] the resulting table
    def bloom(items=[], options={})
      @seedling.adapter.sprout(@seedling, @seedling.options.merge(options).merge(
        :attributes => @seedling.row.attributes,
        :items => items
      ))
    end

    # Provides bulk importing
    # @param [Hash] options
    # @option options [Hash,String] :with (required) a Hash of identity (id) => attribute pairs, or a String to a CSV file to update the seedling with
    # @option options [true, false] :preview (false) whether or not to use the previewer
    def photosynthesize(items=[], options={})
      @seedling.adapter.osmosis(@seedling, @seedling.options.merge(options).merge(
        :items => items
      ))
    end

    # Delegates methods to the current seedling
    def method_missing(*args, &blk)
      @seedling.send(*args, &blk)
    end
  end
end