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
  
    def calculate_adjacent_mines
      @grid.each_with_index do |row, y|
        row.each_with_index do |cell, x|
          next if cell.mine
          adjacent_cells(x, y).each do |adj_x, adj_y|
            cell.adjacent_mines += 1 if @grid[adj_y][adj_x].mine
          end
        end
      end
    end
  
    def adjacent_cells(x, y)
      adjacent = []
      (-1..1).each do |dx|
        (-1..1).each do |dy|
          next if dx == 0 && dy == 0
          adj_x, adj_y = x + dx, y + dy
          adjacent << [adj_x, adj_y] if adj_x.between?(0, @width-1) && adj_y.between?(0, @height-1)
        end
      end
      adjacent
    end
  
    def display
      puts "  #{(0...@width).to_a.join(' ')}"
      @grid.each_with_index do |row, index|
        print "#{index} "
        row.each do |cell|
          if cell.revealed
            print cell.mine ? '*' : cell.adjacent_mines.to_s
          else
            print cell.flagged ? 'F' : '?'
          end
          print ' '
        end
        puts
      end
    end
  
    def reveal(x, y)
      cell = @grid[y][x]
      return if cell.revealed || cell.flagged
    
      cell.revealed = true
      if cell.adjacent_mines == 0 && !cell.mine
        adjacent_cells(x, y).each { |adj_x, adj_y| reveal(adj_x, adj_y) }
      end
    end
  
    def reveal_all
      @grid.each do |row|
        row.each do |cell|
          cell.revealed = true
        end
      end
    end
  
    def game_over?
      if @grid.any? { |row| row.any? { |cell| cell.mine && cell.revealed } }
        puts "Поражение! Вы наступили на мину."
        true
      elsif @grid.all? { |row| row.all? { |cell| cell.mine || cell.revealed } }
        puts "Победа!"
        true
      else
        false
      end
    end
  
    def cell_at(x, y)
      @grid[y][x]
    end
  end
  

  class Game

  end

  class Menu

  end
end
