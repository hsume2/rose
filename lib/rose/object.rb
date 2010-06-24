require 'rose'
require 'rose/ruport'

module Rose
  # This class is provides Objects the ability to run reports
  class ObjectAdapter
    class << self
      include CoreExtensions
    end

    # @param [Rose::Seedling] seedling the seedling to sprout
    # @param [Hash] options the options to run with
    # @option options [Array] :items (required) the items to report on
    # @option options [Rose::Attribute::Collection] :attributes (nil) a row of attributes
    # @option options [String] :group_column (nil) @deprecated
    # @option options [String] :pivot_column (nil) @deprecated
    # @option options [String] :value_block (nil) @deprecated
    # @option options [String] :summary (nil) @deprecated
    # @option options [String] :summary_on (nil) @deprecated
    # @option options [String] :sort_by (nil) @deprecated
    # @option options [String] :sort_order (nil) @deprecated
    # @return [Ruport::Data::Table] the resulting table
    def self.sprout(seedling, options={})
      items, attributes = required_values(options, :items, :attributes)
      table = Ruport::Data::RoseTable.new(:column_names => attributes.column_names)

      self.rows(table, options)

      if (alterations = options[:alterations])
        alterations.each do |alteration|
          table = alteration.on(table)
        end
      end

      table
    end

    # @param [Rose::Seedling] seedling the seedling to update
    # @param [Hash] options the options to run with
    # @option options [Array] :items (required) an Array of items
    # @option options [Hash] :updates (required) a Hash of identity (id), attribute pairs
    def self.osmosis(seedling, options={})
      updates_or_csv, items = required_values(options, :updates, :items)

      root = seedling.root
      idy_attr = seedling.row.identity_attribute

      case updates_or_csv
      when String # CSV File
        self.osmosis_from_csv(root, {
          :idy_attr => idy_attr,
          :csv_file => updates_or_csv,
          :items    => items
        })
      when Hash
        self.osmosis_from_hash(root, {
          :idy_attr => idy_attr,
          :updates  => updates_or_csv,
          :items    => items
        })
      end
    end

    protected

    def self.rows(table, options={})
      items, attributes = required_values(options, :items, :attributes)
      items.each do |item|
        options[:class].tap { |enforce_class| enforce_item_type(item, enforce_class) if enforce_class }
        table << attributes.row { |attr| attr.evaluate(item).to_s }
      end
    end

    def self.enforce_item_type(item, klass)
      raise TypeError.new("Expected #{klass}, got #{item.class}") unless item.kind_of?(klass)
    end

    def self.osmosis_from_csv(root, options={})
      idy_attr, csv_file, items = required_values(options, :idy_attr, :csv_file, :items)
      updates = data_from_csv(csv_file).inject({}) do |updates, data|
        updates[data.delete(idy_attr.column_name)] = data
        updates
      end
      self.osmosis_from_hash(root, options.merge(:updates => updates))
    end

    def self.osmosis_from_hash(root, options={})
      idy_attr, updates, items = required_values(options, :idy_attr, :updates, :items)
      finder = root.finder || auto_finder(idy_attr)
      updates.each do |idy, update|
        record = use_finder(finder, items, idy)
        root.updater.call(record, update)
      end
    end

    def self.data_from_csv(csv_file)
      Ruport::Data::RoseTable.load(csv_file).data.map(&:to_hash)
    end

    # @param [Rose::Attribute] idy_attr the attribute to find items with
    # @return [Proc] a Proc that will find items with attribute evaluating to given id
    def self.auto_finder(idy_attr)
      lambda { |items, idy|
        items.find do |item|
          idy_attr.evaluate(item).to_s == idy
        end
      }
    end

    def self.use_finder(finder, items, idy)
      finder.call(items, idy)
    end
  end
end
