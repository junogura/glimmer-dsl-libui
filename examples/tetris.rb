require 'glimmer-dsl-libui'

require_relative 'tetris/model/game'

class Tetris
  include Glimmer
  
  BLOCK_SIZE = 25
  BEVEL_CONSTANT = 20
  COLOR_GRAY = {r: 192, g: 192, b: 192}
    
  attr_reader :game
  
  def initialize
    @game = Model::Game.new
  end
  
  def launch
    create_gui
    register_observers
    @game.start!
    @main_window.show
  end
  
  def create_gui
    @main_window = window('Glimmer Tetris') {
      content_size Model::Game::PLAYFIELD_WIDTH * BLOCK_SIZE, Model::Game::PLAYFIELD_HEIGHT * BLOCK_SIZE + 98
      
      vertical_box {
        label { # filler
          stretchy false
        }
        
        score_board(block_size: BLOCK_SIZE) {
          stretchy false
        }
        
        @playfield_blocks = playfield(playfield_width: Model::Game::PLAYFIELD_WIDTH, playfield_height: Model::Game::PLAYFIELD_HEIGHT, block_size: BLOCK_SIZE)
      }
    }
  end
  
  def register_observers
    Glimmer::DataBinding::Observer.proc do |game_over|
      if game_over
        show_game_over_dialog
      else
        start_moving_tetrominos_down
      end
    end.observe(@game, :game_over)
    
    Model::Game::PLAYFIELD_HEIGHT.times do |row|
      Model::Game::PLAYFIELD_WIDTH.times do |column|
        Glimmer::DataBinding::Observer.proc do |new_color|
          Glimmer::LibUI.queue_main do
            color = Glimmer::LibUI.interpret_color(new_color)
            block = @playfield_blocks[row][column]
            block[:background_square].fill = color
            block[:top_bevel_edge].fill = {r: color[:r] + 4*BEVEL_CONSTANT, g: color[:g] + 4*BEVEL_CONSTANT, b: color[:b] + 4*BEVEL_CONSTANT}
            block[:right_bevel_edge].fill = {r: color[:r] - BEVEL_CONSTANT, g: color[:g] - BEVEL_CONSTANT, b: color[:b] - BEVEL_CONSTANT}
            block[:bottom_bevel_edge].fill = {r: color[:r] - BEVEL_CONSTANT, g: color[:g] - BEVEL_CONSTANT, b: color[:b] - BEVEL_CONSTANT}
            block[:left_bevel_edge].fill = {r: color[:r] - BEVEL_CONSTANT, g: color[:g] - BEVEL_CONSTANT, b: color[:b] - BEVEL_CONSTANT}
            block[:border_square].stroke = new_color == Model::Block::COLOR_CLEAR ? COLOR_GRAY : color
          end
        end.observe(@game.playfield[row][column], :color)
      end
    end
    
    Model::Game::PREVIEW_PLAYFIELD_HEIGHT.times do |row|
      Model::Game::PREVIEW_PLAYFIELD_WIDTH.times do |column|
        Glimmer::DataBinding::Observer.proc do |new_color|
          Glimmer::LibUI.queue_main do
            color = Glimmer::LibUI.interpret_color(new_color)
            block = @preview_playfield_blocks[row][column]
            block[:background_square].fill = color
            block[:top_bevel_edge].fill = {r: color[:r] + 4*BEVEL_CONSTANT, g: color[:g] + 4*BEVEL_CONSTANT, b: color[:b] + 4*BEVEL_CONSTANT}
            block[:right_bevel_edge].fill = {r: color[:r] - BEVEL_CONSTANT, g: color[:g] - BEVEL_CONSTANT, b: color[:b] - BEVEL_CONSTANT}
            block[:bottom_bevel_edge].fill = {r: color[:r] - BEVEL_CONSTANT, g: color[:g] - BEVEL_CONSTANT, b: color[:b] - BEVEL_CONSTANT}
            block[:left_bevel_edge].fill = {r: color[:r] - BEVEL_CONSTANT, g: color[:g] - BEVEL_CONSTANT, b: color[:b] - BEVEL_CONSTANT}
            block[:border_square].stroke = new_color == Model::Block::COLOR_CLEAR ? COLOR_GRAY : color
          end
        end.observe(@game.preview_playfield[row][column], :color)
      end
    end

    Glimmer::DataBinding::Observer.proc do |new_score|
      Glimmer::LibUI.queue_main do
        @score_label.text = new_score.to_s
      end
    end.observe(@game, :score)

    Glimmer::DataBinding::Observer.proc do |new_lines|
      Glimmer::LibUI.queue_main do
        @lines_label.text = new_lines.to_s
      end
    end.observe(@game, :lines)

    Glimmer::DataBinding::Observer.proc do |new_level|
      Glimmer::LibUI.queue_main do
        @level_label.text = new_level.to_s
      end
    end.observe(@game, :level)
  end
  
  def playfield(playfield_width: , playfield_height: , block_size: , &extra_content)
    blocks = []
    vertical_box {
      padded false
      
      playfield_height.times.map do |row|
        blocks << []
        horizontal_box {
          padded false
          
          playfield_width.times.map do |column|
            blocks.last << block(row: row, column: column, block_size: block_size)
          end
        }
      end
      
      extra_content&.call
    }
    blocks
  end
  
  def block(row: , column: , block_size: , &extra_content)
    block = {}
    bevel_pixel_size = 0.16 * block_size.to_f
    color = Glimmer::LibUI.interpret_color(Model::Block::COLOR_CLEAR)
    area {
      block[:background_square] = path {
        square(0, 0, block_size)
        
        fill color
      }
      block[:top_bevel_edge] = path {
        polygon(0, 0, block_size, 0, block_size - bevel_pixel_size, bevel_pixel_size, bevel_pixel_size, bevel_pixel_size)
  
        fill r: color[:r] + 4*BEVEL_CONSTANT, g: color[:g] + 4*BEVEL_CONSTANT, b: color[:b] + 4*BEVEL_CONSTANT
      }
      block[:right_bevel_edge] = path {
        polygon(block_size, 0, block_size - bevel_pixel_size, bevel_pixel_size, block_size - bevel_pixel_size, block_size - bevel_pixel_size, block_size, block_size)
  
        fill r: color[:r] - BEVEL_CONSTANT, g: color[:g] - BEVEL_CONSTANT, b: color[:b] - BEVEL_CONSTANT
      }
      block[:bottom_bevel_edge] = path {
        polygon(block_size, block_size, 0, block_size, bevel_pixel_size, block_size - bevel_pixel_size, block_size - bevel_pixel_size, block_size - bevel_pixel_size)
  
        fill r: color[:r] - BEVEL_CONSTANT, g: color[:g] - BEVEL_CONSTANT, b: color[:b] - BEVEL_CONSTANT
      }
      block[:left_bevel_edge] = path {
        polygon(0, 0, 0, block_size, bevel_pixel_size, block_size - bevel_pixel_size, bevel_pixel_size, bevel_pixel_size)
  
        fill r: color[:r] - BEVEL_CONSTANT, g: color[:g] - BEVEL_CONSTANT, b: color[:b] - BEVEL_CONSTANT
      }
      block[:border_square] = path {
        square(0, 0, block_size)
  
        stroke COLOR_GRAY
      }
      
      on_key_down do |key_event|
        case key_event
        in ext_key: :down
          game.down!
        in key: ' '
          game.down!(instant: true)
        in ext_key: :up
          case game.up_arrow_action
          when :instant_down
            game.down!(instant: true)
          when :rotate_right
            game.rotate!(:right)
          when :rotate_left
            game.rotate!(:left)
          end
        in ext_key: :left
          game.left!
        in ext_key: :right
          game.right!
        in modifier: :shift
          game.rotate!(:right)
        in modifier: :control
          game.rotate!(:left)
        else
          # Do Nothing
        end
      end
      
      extra_content&.call
    }
    block
  end
  
  def score_board(block_size: , &extra_content)
    vertical_box {
      horizontal_box {
        label # filler
        @preview_playfield_blocks = playfield(playfield_width: Model::Game::PREVIEW_PLAYFIELD_WIDTH, playfield_height: Model::Game::PREVIEW_PLAYFIELD_HEIGHT, block_size: block_size)
        label # filler
      }

      horizontal_box {
        label # filler
        grid {
          stretchy false
          
          label('Score') {
            left 0
            top 0
            halign :fill
          }
          @score_label = label {
            left 0
            top 1
            halign :center
          }
    
          label('Lines') {
            left 1
            top 0
            halign :fill
          }
          @lines_label = label {
            left 1
            top 1
            halign :center
          }
    
          label('Level') {
            left 2
            top 0
            halign :fill
          }
          @level_label = label {
            left 2
            top 1
            halign :center
          }
        }
        label # filler
      }
    
      extra_content&.call
    }
  end
  
  def start_moving_tetrominos_down
    Glimmer::LibUI.timer(@game.delay) do
      @game.down! if !@game.game_over? && !@game.paused?
    end
  end
  
  def show_game_over_dialog
    Glimmer::LibUI.queue_main do
      msg_box('Game Over', "Score: #{@game.high_scores.first.score}\nLines: #{@game.high_scores.first.lines}\nLevel: #{@game.high_scores.first.level}")
      @game.restart!
    end
  end
end

Tetris.new.launch
