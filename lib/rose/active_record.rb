require 'rose'
require 'active_record'

module Rose
  # This class is provides ActiveRecord models the ability to run reports
  class ActiveRecordAdapter < ObjectAdapter
    # @see Rose::ObjectAdapter#sprout
    def self.sprout(row, items=[], options={})
      table = nil
      options[:class].transaction do
        table = super(row, items, options)
        raise ActiveRecord::Rollback
      end
      table
    end

    # @see Rose::ObjectAdapter#osmosis
    def self.osmosis(root, updates={}, options={})
      updates.each do |idy, update|
        record = root.finder.call(idy)
        root.updater.call(record, update)
      end
    end
  end

  module ActiveRecordExtensions
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def rose(name, options={}, &blk)
        instance = Rose::Seedling.new(Rose::ActiveRecordAdapter, options.merge(:class => self))
        instance.instance_eval(&blk)
        register_seedling(name, instance)
      end

      def rose_for(name, *args)
        seedlings(name).bloom(self.find(:all, *args))
      end

      def seedlings(name)
        @seedlings ||= {}
        @seedlings[name]
      end

      private

      def register_seedling(name, instance)
        @seedlings ||= {}
        @seedlings[name] = Shell.new(instance)
      end
    end
  end
end

# This extends ActiveRecord::Base to include Rose reporting
class ActiveRecord::Base
  include Rose::ActiveRecordExtensions
end