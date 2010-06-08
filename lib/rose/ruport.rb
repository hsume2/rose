# Enables pivoting with value columns
class Ruport::Data::RoseTable < Ruport::Data::Table
  def pivot(pivot_column, options = {})
    group_column = options[:group_by] ||
      raise(ArgumentError, ":group_by option required")
    value_column = options[:values]   ||
      raise(ArgumentError, ":values option required")
    RosePivot.new(
      self, group_column, pivot_column, nil, options
    ).to_table(&value_column)
  end

  def grouped_rows(with, column_name)
    rows_with(with).map { |row|
      begin
        row.send(column_name.to_sym)
      rescue NoMethodError => no_method_error
        nil
      end
    }
  end
end

# Enables using value blocks for the value column
class Ruport::Data::Table::RosePivot < Ruport::Data::Table::Pivot
  def to_table
    result = Table()
    result.add_column(@group_column)
    pivoted_columns = columns_from_pivot
    pivoted_columns.each { |name| result.add_column(name) }
    outer_grouping = Grouping(@table, :by => @group_column)
    group_column_entries.each {|outer_group_name|
      outer_group = outer_grouping[outer_group_name]
      pivot_values = pivoted_columns.inject({}) do |hsh, pc|
        matching_rows = outer_group.rows_with(@pivot_column => pc)
        hsh[pc] = yield(matching_rows)
        hsh
      end
      result << [outer_group_name] + pivoted_columns.map {|pc|
        pivot_values[pc]
      }
    }
    result
  end
end