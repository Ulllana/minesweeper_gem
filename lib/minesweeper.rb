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
  
    # Инициализация ширины, высоты и количества мин. Инициализация новой доски
    def initialize(width, height, num_mines)
      @width, @height, @num_mines = width, height, num_mines
      @grid = Array.new(height) { Array.new(width) { Cell.new } }
      place_mines
      calculate_adjacent_mines
    end
  
    # Случайная постановка мин на поле
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
  
    # Рассчет количества соседних мин для каждой ячейки
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
  
    # Вспомогательный метод для нахождения координат соседних ячеек
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
  
    # Отображение состояния доски в консоли
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
  
    # Открытие ячейки по заданным координатам
    def reveal(x, y)
      cell = @grid[y][x]
      return if cell.revealed || cell.flagged
    
      cell.revealed = true
      if cell.adjacent_mines == 0 && !cell.mine
        adjacent_cells(x, y).each { |adj_x, adj_y| reveal(adj_x, adj_y) }
      end
    end
  
    # Открытие всех ячеек (при поражении)
    def reveal_all
      @grid.each do |row|
        row.each do |cell|
          cell.revealed = true
        end
      end
    end
  
    # Проверка, окончена ли игра (победа/поражение)
    def game_over?
      system "clear" or system "cls"
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
    def initialize(width, height, num_mines)
      @board = Board.new(width, height, num_mines)
      @game_over = false
    end
  
    def play
      until @game_over
        system "clear" or system "cls"
        @board.display
        puts "Управление: (r x y для открытия клетки, f x y чтобы отметить/снять отметку, q завершить игру):"
        input = gets.chomp
        handle_input(input)
        if @game_over
          @board.reveal_all  
          @board.display  
          puts "Игра окончена! Нажмите любую клавишу, чтобы выйти."
          gets
        end
      end
    end
    
    def handle_input(input)
      command, x, y = input.split
      x = x.to_i
      y = y.to_i
  
      case command.downcase
      when 'r'
        @board.reveal(x, y)
        @game_over = @board.game_over?
      when 'f'
        cell = @board.cell_at(x, y)
        cell.flagged = !cell.flagged unless cell.revealed
      when 'q'
        puts "Выход..."
        @game_over = true
      else
        puts "Неправильный ввод."
      end
    end
  end

  class Menu
    def start_game
      puts "Добро пожаловать в Сапёр!"
      puts "Выберите сложность или создайте свою игру:"
      puts "1 - Своя игра"
      puts "2 - Легкий"
      puts "3 - Средний"
      puts "4 - Сложный"
    
      print "Выберите (1-4): "
      choice = gets.chomp.to_i
    
      case choice
      when 1
        print "Введите ширину поля: "
        width = gets.chomp.to_i
        print "Введите высоту поля: "
        height = gets.chomp.to_i
        print "Введите количество мин: "
        num_mines = gets.chomp.to_i
      when 2
        # Легкая сложность
        width, height, num_mines = 9, 9, 10
      when 3
        # Средняя сложность
        width, height, num_mines = 16, 16, 40
      when 4
        # Тяжелая сложность
        width, height, num_mines = 30, 16, 99
      else
        puts "Неправильный ввод. Игра начнется в легком режиме."
        width, height, num_mines = 9, 9, 10
      end
    
      game = Game.new(width, height, num_mines)
      game.play
    end
  end
  
  def play_game
    menu = Menu.new()
    menu.start_game
  end
end
