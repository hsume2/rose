module Rose
  # This should probably be called Cell
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

    # This class defines a Cell whose value is defined via a block
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

    # This class defines a Cell whose value is defined via a method
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
      attr_reader :column_name, :order

      def initialize(column_name, order)
        @column_name = column_name
        @order       = order
      end

      def on(table)
        table.sort_rows_by!(@column_name, :order => @order)
        table
      end
    end
  end
end