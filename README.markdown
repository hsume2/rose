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

## Making a Report

    class Flower < Struct.new(:type, :color, :age)
    end

    Rose.make(:poem, :class => Flower) do
      rows do
        column(:type => "Type")
        column("Color", &:color)
      end
    end

## Running a Report

    Rose(:poem).bloom([Flower.new(:roses, :red), Flower.new(:violets, :blue)])

    +-----------------+
    |  Type   | Color |
    +-----------------+
    | roses   | red   |
    | violets | blue  |
    +-----------------+

## Sorting

    Rose.make(:with_sort_by_age_descending, :class => Flower) {
      rows do
        column(:type => "Type")
        column(:color => "Color")
        column(:age => "Age")
      end
      sort("Age", :descending)
    }

## Filtering

    Rose.make(:with_filter, :class => Flower) {
      rows do
        column(:type => "Type")
        column(:color => "Color")
        column(:age => "Age")
      end
      filter do |row|
        row["Color"] != "blue"
      end
    }

## Summarizing

    Rose.make(:with_summary, :class => Flower) {
      rows do
        column(:type => "Type")
        column(:color => "Color")
      end
      summary("Type") do
        column("Color") { |colors| colors.uniq.join(", ") }
        column("Count") { |colors| colors.size }
      end
    }

## Pivoting

    Rose.make(:with_pivot, :class => Flower) {
      rows do
        column(:type => "Type")
        column(:color => "Color")
        column(:age => "Age")
      end
      pivot("Color", "Type") do |rows|
        rows.map(&:Age).map(&:to_i).inject(0) { |sum,x| sum+x }
      end
    }

## Importing

    Rose.make(:with_find_and_update) do
      rows do
        identity(:id => "ID")
        column(:type => "Type")
        column(:color => "Color")
        column(:age => "Age")
      end
      roots do
        # find is optional. By default will return items with item["ID"] == idy
        find do |items, idy|
          items.find { |item| item.id.to_s == idy }
        end
        update do |item, updates|
          item.color = updates["Color"]
        end
      end
    end

`#identity` must be used for one column. Without it `Rose` won't be able to identify which items to update.

### Manually

    Rose(:with_find_and_update).photosynthesize(@flowers, {
      :updates => {
        "0" => { "Color" => "blue" }
        # ID => Updates
      }
    })

### CSV

    Rose(:with_find_and_update).photosynthesize(@flowers, {
      :csv_file => "change_flowers.csv"
    })

### Preview

    Rose.make(:with_preview) do
      rows do
        identity(:id => "ID")
        column(:type => "Type")
        column(:color => "Color")
        column(:age => "Age")
      end
      roots do
        preview_update do |item, updates|
          item.preview(true); item.color = updates["Color"]
        end
        update { raise Exception, "you shouldn't be calling me" }
      end
    end

    Rose(:with_preview).photosynthesize(@flowers, {
      :updates => {
        "0" => { "Color" => "blue" }
      },
      :preview => true
    })

    Rose(:with_preview).photosynthesize(@flowers, {
      :csv_file => "change_flowers.csv",
      :preview  => true
    })

# ActiveRecord

First, use the ActiveRecord adapter:

    config.gem 'rose', :lib => 'rose/active_record'

For the most part, the ActiveRecord adapter has the same interface as the ObjectAdapter, except for the following differences:

## Making a Report

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

## Running a Report

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

`Employee#rose_for` is a helper method that blooms on Employee.find(:all, :conditions => ["salary <> ?", nil]). If you still want direct access to your report, you can use `Employee.seedlings(:department_salaries)`

## Importing (with Preview)

    Post.rose(:for_update) {
      rows do
        identity(:guid => "ID")
        column("Title", &:title)
        column("Comments") { |item| item.comments.size }
      end

      sort("Comments", :descending)

      roots do
        find do |items, idy|
          items.find { |item| item.guid == idy }
        end
        preview_create do |idy, updates|
          post = Post.new(:guid => idy)
          post.title = updates["Title"]
          post
        end
        create do |idy, updates|
          post = create_previewer.call(idy, updates)
          post.save!
          post
        end
        preview_update do |record, updates|
          record.title = updates["Title"]
        end
        update do |record, updates|
          record.update_attribute(:title, updates["Title"])
        end
      end
    }

    Post.root_for(:for_update, {
      :with => {
        "1" => { "Title" => "New Title" }
      },
      :preview => true
    }) # => Returns a table

    Post.root_for(:for_update, {
      :with => "change_flowers.csv"
      :preview  => true
    })

*****

# Other

Inspired by `Machinist` and `factory_girl`

*****

# Future

* Documentation

*****

# Copyright

Copyright (c) 2010 Henry Hsu. See LICENSE for details.