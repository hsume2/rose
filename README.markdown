# rose

Rose (say it out loud: rows, rows, rows) is a slick Ruby DSL for reporting:

    Rose.make(:worlds) do
      rows do
        column(:hello => "Hello")
        column(:world)
      end
    end
    
    class World < Struct.new(:hello, :world)
    end
    
    Rose(:worlds).bloom([World.new("Say", "what?")]).to_s
    
    +---------------+
    | Hello | world |
    +---------------+
    | Say   | what? |
    +---------------+

Install the gem:

    gem install rose


*****

# Usage

    class Flower < Struct.new(:type, :color, :age)
    end
    
    Rose.make(:poem, :class => Flower) do
      rows do
        column(:type => "Type")
        column("Color", &:color)
      end
    end
    
    Rose(:poem).bloom([Flower.new(:roses, :red), Flower.new(:violets, :blue)])
    
    +-----------------+
    |  Type   | Color |
    +-----------------+
    | roses   | red   |
    | violets | blue  |
    +-----------------+

## ActiveRecord

First, use the ActiveRecord adapter:

    config.gem 'rose', :lib => 'rose/active_record'

Then:
  
    Employee.rose(:department_salaries) do
      rows do
        column("Name") { |e| "#{e.firstname} #{e.lastname}" }
        column("Department") { |e| e.department.name }
        column("Salary") { |e| e.salary }
      end
      summary("Department") do
        column("Salary") { |salaries| salaries.map(&:to_i).sum }
      end
    end
    
    Employee.rose_for(:department_salaries, :conditions => ["salary <> ?", nil])
    
    +----------------------+
    | Department  | Salary |
    +----------------------+
    | Accounting  |  85000 |
    | Admin       |  69000 |
    | Sales       | 120000 |
    | Engineering | 122000 |
    | IT          |  50000 |
    | Graphics    |  42000 |
    +----------------------+

*****

# Other

Inspired by `Machinist` and `factory_girl`

*****

# Future

* Two-way reporting
* Filtering documentation
* Documentation

*****

# Copyright

Copyright (c) 2010 Henry Hsu. See LICENSE for details.