# frozen_string_literal: true

require_relative "minesweeper/version"

module Minesweeper
  class Error < StandardError; end
  class Cell
    attr_accessor :mine, :flagged, :revealed, :adjacent_mines
  
    def initialize
      @mine = false
      @flagged = false
      @revealed = false
      @adjacent_mines = 0
    end
  end

  class Board
    attr_reader :width, :height, :num_mines
  
    def initialize(width, height, num_mines)
      @width, @height, @num_mines = width, height, num_mines
      @grid = Array.new(height) { Array.new(width) { Cell.new } }
      place_mines
      calculate_adjacent_mines
    end
  
    def place_mines
      placed_mines = 0
      while placed_mines < @num_mines
        rand_x = rand(@width)
        rand_y = rand(@height)
    
        unless @grid[rand_y][rand_x].mine
          @grid[rand_y][rand_x].mine = true
          placed_mines += 1
        end
      end
    end
  end

  class Game

  end

  class Menu

  end
end
