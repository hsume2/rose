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
    # @option options [Hash,String] :with (required) (see Rose::Shell#photosynthesize)
    def self.osmosis(seedling, options={})
      hash_or_csv, items = required_values(options, :with, :items)

      root, row = seedling.root, seedling.row
      idy_attr = row.identity_attribute

      items = case hash_or_csv
      when String # CSV File
        self.osmosis_from_csv(root, options.merge(
          :idy_attr => idy_attr,
          :csv_file => hash_or_csv,
          :items    => items
        ))
      when Hash
        self.osmosis_from_hash(root, options.merge(
          :idy_attr => idy_attr,
          :updates  => hash_or_csv,
          :items    => items
        ))
      end

      self.sprout(seedling, options.merge(
        :attributes => row.attributes,
        :items      => items
      ))
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

    # @return [Array] items (see Rose::ObjectAdapter#osmosis_from_hash)
    def self.osmosis_from_csv(root, options={})
      idy_attr, csv_file, items = required_values(options, :idy_attr, :csv_file, :items)
      updates = data_from_csv(csv_file).inject({}) do |updates, data|
        updates[data.delete(idy_attr.column_name)] = data
        updates
      end
      self.osmosis_from_hash(root, options.merge(:updates => updates))
    end

    # @return [Array] items the updated items
    def self.osmosis_from_hash(root, options={})
      idy_attr, updates, items = required_values(options, :idy_attr, :updates, :items)
      finder = root.finder || auto_finder(idy_attr)
      new_items = []
      updates.each do |idy, update|
        record = use_finder(finder, items, idy)
        if record
          root.updater(options[:preview]).call(record, update)
        elsif creator = root.creator(options[:preview])
          new_items << creator.call(idy, update)
        else
          next
        end
      end
      items | new_items
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

    # In case subclasses want to call finders differently
    def self.use_finder(finder, items, idy)
      finder.call(items, idy)
    end
  end
end
