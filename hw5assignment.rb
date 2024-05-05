# CSCE 314: Programming Languages, Homework 5, hw5assignment.rb

# This is the only file you turn in, so do not modify the other files as
# part of your solution.

class MyPiece < Piece
  # The constant All_My_Pieces should be declared here
  All_My_Pieces = All_Pieces.concat([rotations([[0,0],[1,0],[0,1]]), #corner
                  rotations([[0,0],[0,1],[1,0],[1,1],[0,2]]), #block with nub
                  [[[-2,0],[-1,0],[0,0],[1,0],[2,0]],
                  [[0,-2],[0,-1],[0,0],[0,1],[0,2]]]]) #long line
  
  Cheat_Piece = [[[0,0]]]

  # your enhancements here
  def self.next_piece (board)
    if !(board.cheat)
      MyPiece.new(All_My_Pieces.sample,board)
    else
      board.reset_cheat
      MyPiece.new(Cheat_Piece,board)
    end
  end

end

class MyBoard < Board
  def initialize(board)
    super(board)
    @cheat = false
  end

  def rotate_flip
    self.rotate_clockwise
    self.rotate_clockwise
  end

  def next_piece
    @current_block = MyPiece.next_piece(self);
    @current_pos = nil
  end

  def store_current #need to overwrite this because the Piece method assumes that the piece has 4 squares
    locations = @current_block.current_rotation
    displacement = @current_block.position
    (0..@current_pos.size().-(1)).each{|index| 
      current = locations[index];
      @grid[current[1]+displacement[1]][current[0]+displacement[0]] = 
      @current_pos[index]
    }
    remove_filled
    @delay = [@delay - 2, 80].max
  end

  def cheat
    @cheat
  end

  def reset_cheat
    @cheat = false
  end

  def do_cheat
    if (!cheat && score > 99)
      @cheat = true
      @score = @score - 100
    end
  end


end

class MyTetris < Tetris
  # your enhancements here
  def set_board
    @canvas = TetrisCanvas.new
    @board = MyBoard.new(self);
    @canvas.place(@board.block_size * @board.num_rows + 3,
                  @board.block_size * @board.num_columns + 6, 24, 80)
    @board.draw
  end

  def key_bindings
    super
    @root.bind('u', proc {@board.rotate_flip})
    @root.bind('c', proc {@board.do_cheat}) #unfinished method
  end


end



class MyTetrisChallenge < MyTetris
  def set_board
    @canvas = TetrisCanvas.new
    @board = MyBoardChallenge.new(self);
    @canvas.place(@board.block_size * @board.num_rows + 3,
                  @board.block_size * @board.num_columns + 6, 24, 80)
    @board.draw
  end


  def draw_ghost (piece, old=nil)
    if old != nil and piece.moved
      old.each{|block| block.remove}
    end

    size = @board.block_size
    blocks = piece.current_rotation
    start = piece.ghost_position
    clipping = false
    while !clipping
      clipping = false
      blocks.map{|block|
        if !(@board.empty_at([block[0] + start[0],
          block[1] + start[1]]))
          clipping = true
        end
      }
      if !clipping
        start = [start[0],start[1]+1]
      else
        start = [start[0],start[1]-1]
      end
    end
    blocks.map{|block| 
    TetrisRect.new(@canvas, start[0]*size + block[0]*size + 3, 
                       start[1]*size + block[1]*size,
                       start[0]*size + size + block[0]*size + 3, 
                       start[1]*size + size + block[1]*size, 
                       'gray57')}
  end

end

class MyPieceChallenge < MyPiece
  def ghost_position
    [@base_position[0],1]
  end

  def self.next_piece (board)
    if !(board.cheat)
      MyPieceChallenge.new(All_My_Pieces.sample,board)
    else
      board.reset_cheat
      MyPieceChallenge.new(Cheat_Piece,board)
    end
  end
    
end

class MyBoardChallenge < MyBoard
  def initialize (game)
    @grid = Array.new(num_rows) {Array.new(num_columns)}
    @current_block = MyPieceChallenge.next_piece(self)
    @score = 0
    @game = game
    @delay = 500
    @cheat = false
    @ghost_pos = nil
  end
  
  def draw
    @ghost_pos = @game.draw_ghost(@current_block,@ghost_pos);
    super
  end

  def next_piece
    @current_block = MyPieceChallenge.next_piece(self);
    @current_pos = nil
  end

  def drop_all_the_way
    if @game.is_running?
      @ghost_pos.each{|block| block.remove}
    end
    super
  end
end