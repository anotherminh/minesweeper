require_relative 'tile'

class Board
  attr_reader :size
  def initialize(size = 9, setting = 'm')
    @grid ||= Array.new(size) { Array.new(size) }
    @size = size
    @num_bombs = calculate_num_bombs(setting)
    populate_tiles
  end

  def calculate_num_bombs(setting)
    case setting
    when 'e'
      size ** 2 / 10
    when 'm'
      size ** 2 / 5
    else
      size ** 2 / 3
    end
  end

  def populate_tiles
    @grid.each_with_index do |row, x|
      row.each_with_index do |cell, y|
        @grid[x][y] = Tile.new(self, [x,y])
      end
    end

    populate_bombs
  end

  def populate_bombs
    @grid.flatten.sample(@num_bombs).each { |tile| tile.bomb! }
  end

  # loop
  #   tile.bomb!
  #   tile.value = :bomb
  # do
  def reveal_tile(pos)
    self[*pos].reveal
  end

  def flag_tile(pos)
    self[*pos].flag!
  end

  def [](row, col)
    @grid[row][col]
  end

  def []=(row, col, mark)
    @grid[row][col] = mark
  end

  def valid_position?(pos)
    pos.all? { |coor| coor >= 0 && coor < size }
  end

  def render
    @grid.each do |row|
      line = ""
      row.each do |cell|
        line += cell.symbol + " "
      end
      puts line
    end
  end

  def reveal_all
    @grid.each do |row|
      row.each do |cell|
        cell.reveal
      end
    end
  end

  def game_over?
    @grid.each do |row|
      row.each do |cell|
        return -1 if cell.state == :reveal && cell.value == :bomb
      end
    end

    reveal_count = 0
    @grid.each do |row|
      row.each do |cell|
        reveal_count += 1 if cell.state == :reveal
      end
    end

    if reveal_count == size**2 - @num_bombs
      return 0
    else
      return 1
    end
  end
end
