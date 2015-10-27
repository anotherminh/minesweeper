require_relative 'board.rb'
require 'yaml'
require 'colorize'

class Minesweeper
  attr_reader :board
  def initialize(board)
    @board = board
  end

  def play_round
    system "clear"
    board.render
    move, action = get_move
    make_move(move, action)
    try_to_save
  end

  def get_move
    valid_location = false
    valid_action = false
    move = nil
    action = nil

    until valid_location && valid_action
      puts "Make your move."
      move_input = gets.chomp.split(', ')
      move = move_input.map { |el| Integer(el) } if move_input.count == 2
      puts "Flag or reveal? (f/r)"
      action = gets.chomp.to_s
      valid_action = true if (action == 'f' || action == 'r')
      valid_location = true if !move.nil? && move.all? { |coor| coor >= 0 && coor < board.size }
      puts "Not a valid move/action" unless valid_location && valid_action
    end
    [move, action]
  end

  def make_move(move, action)
    if action == 'f'
      board.flag_tile(move)
    elsif action == 'r'
      board.reveal_tile(move)
    end
  end

  def play
    until board.game_over? <= 0
      play_round
    end
    board.reveal_all
    board.render
    if board.game_over? == -1
      puts "Game over! You're a loser."
    else
      puts "Game over! You won...this time."
    end
  end

  def try_to_save
    puts "\'s\' to save. Enter to continue."
    input = gets

    if input == "s\n"
      puts "Name your file:"
      file_name = gets.chomp
      File.write("./#{file_name}.yaml", self.to_yaml)
      Kernel.abort
    else
      return
    end
  end
end

if(__FILE__ == $PROGRAM_NAME)
  if ARGV.empty?
    puts "Choose your difficulty setting! (e/m/h)"
    setting = gets.chomp
    puts "Choose the grid size! Type \'8\' for an 8x8 grid."
    size = Integer(gets.chomp)
    board = Board.new(size, setting)
    game = Minesweeper.new(board)
    game.play
  else
    load_file_name = ARGV.shift
    YAML.load_file(load_file_name).play
  end
end
