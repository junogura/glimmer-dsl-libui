require_relative 'vertebra'
  
class Snake
  module Model
    class Snake
#       attr_accessor :collided
#       alias collided? collided
      
      attr_reader :game
      # vertebrae and joins are ordered from tail to head
      attr_accessor :vertebrae
      
      def initialize(game)
        @game = game
      end
      
      # generates a new snake location and orientation from scratch or via dependency injection of what head_cell and orientation are (for testing purposes)
      def generate(initial_row: nil, initial_column: nil, initial_orientation: nil)
        initial_vertebra = Vertebra.new(snake: self, row: initial_row, column: initial_column, orientation: initial_orientation)
        self.vertebrae = [initial_vertebra]
      end
      
      def length
        @vertebrae.length
      end
      
      def head
        @vertebrae.last
      end
      
      def remove
        self.vertebrae.clear
        self.joins.clear
      end
      
      def move
        @vertebrae.each do |vertebra|
          case vertebra.orientation
          when :east
            vertebra.column = (vertebra.column + 1) % @game.width
          when :west
            vertebra.column = (vertebra.column - 1) % @game.width
          when :south
            vertebra.row = (vertebra.row + 1) % @game.height
          when :north
            vertebra.row = (vertebra.row - 1) % @game.height
          end
        end
      end
      
      def turn_left
      end
      
      def turn_right
        case head.orientation
        when :east
          head.orientation = :south
        when :west
          head.orientation = :north
        when :south
          head.orientation = :west
        when :north
          head.orientation = :east
        end
      end
      
      def grow
      end
      
      # inspect is overridden to prevent printing very long stack traces
      def inspect
        "#{super[0, 150]}... >"
      end
    end
  end
end
