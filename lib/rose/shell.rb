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
    def bloom(items=[])
      @seedling.adapter.sprout(@seedling.row, items, @seedling.options)
    end

    # Provides bulk importing
    # @param [Hash] updates the changes to update the seedling with
    def photosynthesize(updates={})
      @seedling.adapter.osmosis(@seedling.root, updates, @seedling.options)
    end

    # Delegates methods to the current seedling
    def method_missing(*args, &blk)
      @seedling.send(*args, &blk)
    end
  end
end