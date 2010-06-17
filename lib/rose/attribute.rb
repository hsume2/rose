module Rose
  # An Attribute is value object used to operate on a table
  class Attribute
    attr_reader :method_name
    attr_reader :column_name

    def initialize(method_name, column_name)
      @method_name = method_name
      @column_name = column_name
    end

    def column_name
      @column_name || @method_name
    end

    # This class defines an Attribute whose value is defined via a block
    class Indirect < Attribute
      attr_reader :value_block

      def initialize(method_name, column_name, value_block)
        super(method_name, column_name)
        @value_block = value_block
      end

      def evaluate(item)
        item.instance_eval(&@value_block)
      end
    end

    # This class defines an Attribute whose value is defined via a method
    class Direct < Attribute
      def evaluate(item)
        if item.respond_to?(@method_name.to_sym)
          item.__send__(@method_name)
        end
      end
    end

    # This is a value object for pivot parameters
    class Pivot < Indirect
      alias_method :group_column, :method_name
      alias_method :pivot_column, :column_name

      def on(table)
        table.pivot(pivot_column, :group_by => group_column, :values => value_block)
      end
    end

    # Defines a collection of attributes
    class Collection < Array
      def row
        inject({}) do |row, attribute|
          row[attribute.column_name] = yield(attribute) if block_given?
          row
        end
      end

      def column_names
        map(&:column_name)
      end
    end

    # This is a value object for sort parameters
    class Sort
      attr_reader :column_name, :order, :sort_block

      def initialize(column_name, order, &sort_block)
        @column_name = column_name
        @order       = order
        @sort_block  = sort_block
      end

      def on(table)
        if @sort_block
          table.sort_rows_by!(nil, :order => @order) do |row|
            @sort_block.call(row[@column_name])
          end
        else
          table.sort_rows_by!(@column_name, :order => @order)
        end
        table
      end
    end

    # This class defines an Indirect Attribute for rejecting table rows
    class Filter < Indirect
      def on(table)
        table.data.reject! { |record| !@value_block.call(record) }
        table
      end
    end
  end
end