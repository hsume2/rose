require 'ruport'

module Rose
  autoload :Seedling, 'rose/seedling'
  autoload :ObjectAdapter, 'rose/object'
  autoload :ActiveRecordAdapter, 'rose/active_record'

  class << self
    attr_accessor :seedlings
  end

  self.seedlings = {}

  def self.make(name, options={}, &blk)
    instance = Rose::Seedling.new(Rose::ObjectAdapter, options)
    instance.instance_eval(&blk)
    self.seedlings[name] = instance
  end
end

# @param [Symbol] name the name of the seedling
# @return [Seedling]
def Rose(name)
  Rose.seedlings[name]
end
