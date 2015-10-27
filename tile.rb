require 'colorize'

class Tile
  attr_reader :value, :location, :neighbor_cells, :board
  attr_accessor :state

  def initialize(board, location)
    @value = nil
    @state = :hidden
    @location = location
    @board = board
    @neighbor_cells = neighbor_locations
  end

  def reveal
    if self.state == :flag || self.state == :reveal
      return
    end

    self.state = :reveal
    return if self.value == :bomb
    bomb_count = self.neighbor_bomb_count
    @value = bomb_count
    if bomb_count == 0 && state != :flag
      @neighbor_cells.each { |cell| board[*cell].reveal }
    end
    nil
  end

  def flag!
    self.state = :flag unless self.state == :reveal
  end

  def bomb!
    @value = :bomb
  end

  def neighbor_bomb_count
    neighbor_tiles = []
    @neighbor_cells.each do |location|
      neighbor_tiles << board[*location]
    end

    count = (neighbor_tiles.select { |tile| tile.value == :bomb }).count
  end

  def neighbor_locations
    neighbor_cells = []
    [-1, 0, 1].each do |delta_x|
      [-1, 0, 1].each do |delta_y|
        possible_neighbor = [@location[0] + delta_x, @location[1] + delta_y]
        if board.valid_position?(possible_neighbor) && possible_neighbor != self.location
          neighbor_cells << possible_neighbor
        end
      end
    end
    neighbor_cells
  end

  def inspect
    [@location.to_s, @value, @state.to_s]
  end

  def symbol
    if @state == :hidden
      "\u2764".colorize(:red)
    elsif @state == :flag
      "\u26FF".colorize(:blue)
    elsif @value == :bomb
      "\u2743".colorize(:yellow)
    else
      nearby_bombs = self.neighbor_bomb_count
      nearby_bombs == 0 ? "_".colorize(:green) : nearby_bombs.to_s.colorize(:light_magenta)
    end
  end
end
