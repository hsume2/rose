require 'spec_helper'

class RoseyObject < Struct.new(:petals, :thorns)
end

class Flower < Struct.new(:id, :type, :color, :age)
end

describe Rose, "Object adapter" do
  before do
    Rose.make(:with_direct_attrs) {
      rows do
        column :petals
        column :thorns
      end
    }

    Rose.make(:with_named_direct_attrs) {
      rows do
        column(:petals => "Petals")
        column(:thorns => "Thorns")
      end
    }

    Rose.make(:with_named_indirect_attrs) {
      rows do
        column("Petals") { |item| item.petals - 1 }
        column("Thorns", &:thorns)
      end
    }

    Rose.make(:with_enforced_class, :class => RoseyObject) {
      rows do
        column :petals
        column :thorns
      end
    }

    Rose.make(:with_summary, :class => Flower) {
      rows do
        column("Type", &:type)
        column(:color => "Color")
      end
      summary("Type") do
        column("Color") { |colors| colors.join(", ") }
      end
    }

    Rose.make(:with_blank_summary, :class => Flower) {
      rows do
        column("Type", &:type)
        column(:color => "Color")
      end
      summary("Type") do
      end
    }

    Rose.make(:with_additional_summary, :class => Flower) {
      rows do
        column("Type", &:type)
        column(:color => "Color")
      end
      summary("Type") do
        column("Color") { |colors| colors.uniq.join(", ") }
        column("Count") { |colors| colors.size }
        column("Count 2") { |colors| colors.size }
      end
    }

    @value_block = value_block = lambda { |rows| rows.map(&:Age).map(&:to_i).inject(0) { |sum,x| sum+x } }

    Rose.make(:with_pivot, :class => Flower) {
      rows do
        column(:type => "Type")
        column(:color => "Color")
        column(:age => "Age")
      end
      pivot("Color", "Type", &value_block)
    }

    Rose.make(:with_sort_by_color, :class => Flower) {
      rows do
        column("Type", &:type)
        column(:color => "Color")
      end
      sort("Color")
    }

    Rose.make(:with_sort_by_color_descending, :class => Flower) {
      rows do
        column("Type", &:type)
        column(:color => "Color")
      end
      sort("Color", :descending)
    }

    Rose.make(:with_sort_by_age, :class => Flower) {
      rows do
        column(:type => "Type")
        column(:color => "Color")
        column(:age => "Age")
      end
      sort("Age")
    }

    Rose.make(:with_sort_by_age_descending, :class => Flower) {
      rows do
        column(:type => "Type")
        column(:color => "Color")
        column(:age => "Age")
      end
      sort("Age", :descending)
    }

    @negative_sort_block = negative_sort_block = lambda { |v| v.to_i * -1 }
    @positive_sort_block = positive_sort_block = lambda { |v| v.to_i }

    Rose.make(:with_sort_by_block_negative, :class => Flower) {
      rows do
        column(:type => "Type")
        column(:age => "Age")
      end
      sort("Age", :descending, &negative_sort_block)
    }

    Rose.make(:with_sort_by_block_positive, :class => Flower) {
      rows do
        column(:type => "Type")
        column(:age => "Age")
      end
      sort("Age", :descending, &positive_sort_block)
    }

    Rose.make(:with_ordered_execution_asc, :class => Flower) {
      rows do
        column("Type", &:type)
        column(:color => "Color")
      end
      sort("Color")
      summary("Type") do
        column("Color") { |colors| colors.join(", ") }
      end
    }

    Rose.make(:with_ordered_execution_desc, :class => Flower) {
      rows do
        column("Type", &:type)
        column(:color => "Color")
      end
      sort("Color", :descending)
      summary("Type") do
        column("Color") { |colors| colors.join(", ") }
      end
    }

    @filter_block = filter_block = lambda { |row| row["Color"] != "blue" }

    Rose.make(:with_filter, :class => Flower) {
      rows do
        column(:type => "Type")
        column(:color => "Color")
        column(:age => "Age")
      end
      filter(&filter_block)
    }

    # @updates_recorder = updates_recorder = []
    @find_block = find_block = lambda { |items, idy|
      items.find { |item| item.id.to_s == idy }
    }
    @update_block = update_block = lambda { |item, updates| item.color = updates["Color"] }
    #
    # Rose.make(:with_update) do
    #   rows do
    #     identity(:id => "ID")
    #     column(:type => "Type")
    #     column(:color => "Color")
    #     column(:age => "Age")
    #   end
    #   roots do
    #     find(&find_block)
    #     update do |item, ups|
    #       item.color = ups["Color"]
    #     end
    #   end
    # end

    Rose.make(:with_find_and_update) do
      rows do
        identity(:id => "ID")
        column(:type => "Type")
        column(:color => "Color")
        column(:age => "Age")
      end
      roots do
        find(&find_block)
        update(&update_block)
      end
    end

    Rose.make(:with_update) do
      rows do
        identity(:id => "ID")
        column(:type => "Type")
        column(:color => "Color")
        column(:age => "Age")
      end
      roots do
        update(&update_block)
      end
    end
  end

  after do
    Rose.seedlings.clear
  end

  context "make report" do
    it "should support bloom and photosynthesize" do
      Rose(:with_direct_attrs).tap do |rose|
        rose.should be_kind_of(Rose::Shell)
        rose.should respond_to(:bloom)
        rose.should respond_to(:photosynthesize)
      end
    end

    it "should support direct attributes" do
      Rose(:with_direct_attrs).tap do |report|
        report.row.attributes.map(&:column_name).should == [:petals, :thorns]
        report.row.attributes.map(&:method_name).should == [:petals, :thorns]
      end
    end

    it "should support direct attributes with column name" do
      Rose(:with_named_direct_attrs).tap do |report|
        report.row.attributes.map(&:column_name).should == ["Petals", "Thorns"]
        report.row.attributes.map(&:method_name).should == [:petals, :thorns]
      end
    end

    it "should support indirect (dynamic) attributes with column name" do
      Rose(:with_named_indirect_attrs).tap do |report|
        report.row.attributes.map(&:column_name).should == ["Petals", "Thorns"]
        report.row.attributes.map(&:method_name).should == ["Petals", "Thorns"]
      end
    end

    it "should support :class option" do
      Rose(:with_enforced_class).tap do |report|
        report.options[:class].should == RoseyObject
      end
    end

    it "should support sort by block" do
      Rose(:with_sort_by_block_negative).tap do |report|
        report.options[:sort].column_name.should == "Age"
        report.options[:sort].order.should == :descending
        report.options[:sort].sort_block.should == @negative_sort_block
      end
    end

    it "should support summary" do
      Rose(:with_summary).tap do |report|
        report.options[:summary].attributes.map(&:column_name).should == ["Color"]
        report.options[:summary].attributes.map(&:method_name).should == ["Color"]
      end
    end

    it "should support pivoting" do
      Rose(:with_pivot).tap do |report|
        report.options[:pivot].group_column.should == "Color"
        report.options[:pivot].pivot_column.should == "Type"
        report.options[:pivot].value_block.should == @value_block
      end
    end

    it "should support filtering" do
      Rose(:with_filter).tap do |report|
        report.options[:filter].value_block.should == @filter_block
      end
    end

    it "should support identity" do
      Rose(:with_update).tap do |report|
        report.row.identity_attribute.column_name.should == "ID"
      end
    end

    it "should support find and update" do
      Rose(:with_find_and_update).tap do |report|
        report.root.finder.should == @find_block
        report.root.updater.should == @update_block
      end
    end
  end

  context "run report" do
    before do
      @arr = [RoseyObject.new(30, 10)]
      @flowers = [
        Flower.new(0, :roses, :red, 1),
        Flower.new(1, :violets, :blue, 2),
        Flower.new(2, :roses, :red, 3)
      ]
    end

    it "should run with direct attributes" do
      Rose(:with_direct_attrs).bloom(@arr).should match_table <<-eo_table.gsub(%r{^      }, '')
      +-----------------+
      | petals | thorns |
      +-----------------+
      | 30     | 10     |
      +-----------------+
      eo_table
    end

    it "should run with direct attributes with column name" do
      Rose(:with_named_direct_attrs).bloom(@arr).should match_table <<-eo_table.gsub(%r{^      }, '')
      +-----------------+
      | Petals | Thorns |
      +-----------------+
      | 30     | 10     |
      +-----------------+
      eo_table
    end

    it "should run with indirect (dynamic) attributes with column name" do
      Rose(:with_named_indirect_attrs).bloom(@arr).should match_table <<-eo_table.gsub(%r{^      }, '')
      +-----------------+
      | Petals | Thorns |
      +-----------------+
      | 29     | 10     |
      +-----------------+
      eo_table
    end

    it "should not run with wrong class" do
      lambda {
        Rose(:with_enforced_class).bloom([mock('Something else')])
      }.should raise_error(TypeError, "Expected RoseyObject, got Mocha::Mock")
    end

    it "should sort by color (ascending)" do
      Rose(:with_sort_by_color).bloom(@flowers).should match_table <<-eo_table.gsub(%r{^      }, '')
      +-----------------+
      |  Type   | Color |
      +-----------------+
      | violets | blue  |
      | roses   | red   |
      | roses   | red   |
      +-----------------+
      eo_table
    end

    it "should sort by color (descending)" do
      Rose(:with_sort_by_color_descending).bloom(@flowers).should match_table <<-eo_table.gsub(%r{^      }, '')
      +-----------------+
      |  Type   | Color |
      +-----------------+
      | roses   | red   |
      | roses   | red   |
      | violets | blue  |
      +-----------------+
      eo_table
    end

    it "should sort by age (ascending)" do
      Rose(:with_sort_by_age).bloom(@flowers).should match_table <<-eo_table.gsub(%r{^      }, '')
      +-----------------------+
      |  Type   | Color | Age |
      +-----------------------+
      | roses   | red   | 1   |
      | violets | blue  | 2   |
      | roses   | red   | 3   |
      +-----------------------+
      eo_table
    end

    it "should sort by age (descending)" do
      Rose(:with_sort_by_age_descending).bloom(@flowers).should match_table <<-eo_table.gsub(%r{^      }, '')
      +-----------------------+
      |  Type   | Color | Age |
      +-----------------------+
      | roses   | red   | 3   |
      | violets | blue  | 2   |
      | roses   | red   | 1   |
      +-----------------------+
      eo_table
    end

    it "should sort by block (-)" do
      Rose(:with_sort_by_block_negative).bloom(@flowers).should match_table <<-eo_table.gsub(%r{^      }, '')
      +---------------+
      |  Type   | Age |
      +---------------+
      | roses   | 1   |
      | violets | 2   |
      | roses   | 3   |
      +---------------+
      eo_table
    end

    it "should sort by block (+)" do
      Rose(:with_sort_by_block_positive).bloom(@flowers).should match_table <<-eo_table.gsub(%r{^      }, '')
      +---------------+
      |  Type   | Age |
      +---------------+
      | roses   | 3   |
      | violets | 2   |
      | roses   | 1   |
      +---------------+
      eo_table
    end

    it "should summarize columns" do
      Rose(:with_summary).bloom(@flowers).should match_table <<-eo_table.gsub(%r{^      }, '')
      +--------------------+
      |  Type   |  Color   |
      +--------------------+
      | roses   | red, red |
      | violets | blue     |
      +--------------------+
      eo_table
    end

    it "should summarize columns omitting columns" do
      Rose(:with_blank_summary).bloom(@flowers).should match_table <<-eo_table.gsub(%r{^      }, '')
      +---------+
      |  Type   |
      +---------+
      | roses   |
      | violets |
      +---------+
      eo_table
    end

    it "should summarize columns adding additional columns" do
      Rose(:with_additional_summary).bloom(@flowers).should match_table <<-eo_table.gsub(%r{^      }, '')
      +-----------------------------------+
      |  Type   | Color | Count | Count 2 |
      +-----------------------------------+
      | roses   | red   |     2 |       2 |
      | violets | blue  |     1 |       1 |
      +-----------------------------------+
      eo_table
    end

    it "should pivot table" do
      Rose(:with_pivot).bloom(@flowers).should match_table <<-eo_table.gsub(%r{^      }, '')
      +-------------------------+
      | Color | roses | violets |
      +-------------------------+
      | red   |     4 |       0 |
      | blue  |     0 |       2 |
      +-------------------------+
      eo_table
    end

    it "should run in order" do
      @flowers << Flower.new(3, :roses, :maroon, 3)
      Rose(:with_ordered_execution_asc).bloom(@flowers).should match_table <<-eo_table.gsub(%r{^      }, '')
      +----------------------------+
      |  Type   |      Color       |
      +----------------------------+
      | violets | blue             |
      | roses   | maroon, red, red |
      +----------------------------+
      eo_table

      Rose(:with_ordered_execution_desc).bloom(@flowers).should match_table <<-eo_table.gsub(%r{^      }, '')
      +----------------------------+
      |  Type   |      Color       |
      +----------------------------+
      | roses   | red, red, maroon |
      | violets | blue             |
      +----------------------------+
      eo_table
    end

    it "should filter rows" do
      Rose(:with_filter).bloom(@flowers).should match_table <<-eo_table.gsub(%r{^      }, '')
      +---------------------+
      | Type  | Color | Age |
      +---------------------+
      | roses | red   | 1   |
      | roses | red   | 3   |
      +---------------------+
      eo_table
    end

    it "should find and update" do
      Rose(:with_find_and_update).photosynthesize({
        "0" => { "Color" => "blue" }
      }, @flowers)

      Rose(:with_find_and_update).bloom(@flowers).should match_table <<-eo_table.gsub(%r{^      }, '')
      +----------------------------+
      | ID |  Type   | Color | Age |
      +----------------------------+
      | 0  | roses   | blue  | 1   |
      | 1  | violets | blue  | 2   |
      | 2  | roses   | red   | 3   |
      +----------------------------+
      eo_table
    end

    it "should update" do
      Rose(:with_update).photosynthesize({
        "0" => { "Color" => "blue" }
      }, @flowers)

      Rose(:with_update).bloom(@flowers).should match_table <<-eo_table.gsub(%r{^      }, '')
      +----------------------------+
      | ID |  Type   | Color | Age |
      +----------------------------+
      | 0  | roses   | blue  | 1   |
      | 1  | violets | blue  | 2   |
      | 2  | roses   | red   | 3   |
      +----------------------------+
      eo_table
    end

    it "should update from CSV" do
      Rose(:with_update).photosynthesize("spec/examples/update_flowers.csv", @flowers)

      Rose(:with_update).bloom(@flowers).should match_table <<-eo_table.gsub(%r{^      }, '')
      +----------------------------+
      | ID |  Type   | Color | Age |
      +----------------------------+
      | 0  | roses   | blue  | 1   |
      | 1  | violets | red   | 2   |
      | 2  | roses   | green | 3   |
      +----------------------------+
      eo_table
    end
  end
end