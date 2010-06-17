require 'ruport'

module Rose
  autoload :Seedling, 'rose/seedling'
  autoload :Shell, 'rose/shell'
  autoload :ObjectAdapter, 'rose/object'
  autoload :ActiveRecordAdapter, 'rose/active_record'

  class << self
    # @return [Hash] global hash of all the named seedlings
    attr_accessor :seedlings
  end

  self.seedlings = {}

  # The generate Rose DSL builder
  # @param [Symbol] name the name of the Seedling to make
  # @param [Hash] options 
  # @option options [Class] :class (nil) Used during by the adapter to enforce items types
  # @return [Seedling] the newly formed Seedling
  def self.make(name, options={}, &blk)
    instance = Rose::Seedling.new(Rose::ObjectAdapter, options)
    instance.instance_eval(&blk)
    self.seedlings[name] = Shell.new(instance)
  end
end

# @param [Symbol] name the name of the seedling
# @return [Seedling] find seedling by name and returns it
def Rose(name)
  Rose.seedlings[name]
end
