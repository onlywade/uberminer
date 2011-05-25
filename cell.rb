require 'rubygems'
require 'rubygame'

include Rubygame

# This class represents a single cell in the map
class Cell
  include Sprites::Sprite
  attr_accessor :sky, :dug, :rock, :x, :y, :rect #this is kind of ridiculous, i probably shouldn't expose so many attributes
  
  # #initialize takes a coordinates array to indicate the position of this cell on the map
  def initialize(coords)
    @coords = coords
    @x, @y = @coords[0], @coords[1]
    
    # Ror now the type of cell is determined by these boolean values.
    # TODO: add a subclass for each type?  I don't know.
    @sky = false
    @dug = false
    @boulder = false
    @ladder = false
    
    # We're just building a square for the surface, at the time being.
    # TODO: use an image appropriate to the cell type
    @image = Surface.new([CELL_SIZE, CELL_SIZE])
    @image.fill(:white)
    
    # We need a Rect to control positioning
    @rect = @image.make_rect

    # Set the position of the rect
    set_center
  end

  # Set the position of this cell's Rect based on cell coords
  def set_center
    xpos = @x * CELL_SIZE + (CELL_SIZE / 2)
    ypos = @y * CELL_SIZE + (CELL_SIZE / 2)
    @rect.center = [xpos, ypos]
  end
  
  # This just draws a nice 1px outline around the cell, to add visual delineation
  def outline
    @image.draw_line([0, 0], [CELL_SIZE - 1, 0], :black)
    @image.draw_line([CELL_SIZE - 1, 0], [CELL_SIZE - 1, CELL_SIZE - 1], :black)
    @image.draw_line([CELL_SIZE - 1, CELL_SIZE - 1], [0, CELL_SIZE - 1], :black)
    @image.draw_line([0, CELL_SIZE - 1], [0,0], :black)
  end
  
  # Hacky method to draw a line across the cell so it looks kind of like a ladder
  def ladderize
    puts "ladderizing"
    @image.draw_line([0, CELL_SIZE / 2], [CELL_SIZE, CELL_SIZE / 2], :black)
  end
  
  # I'm overriding Sprite#draw in order to change color based on cell type, and draw a ladder if needed
  def draw(screen)
    if @sky
      @image.fill(:blue)
    elsif  @dug 
      @image.fill(:brown)
    elsif @rock
      @image.fill(:gray)
    else
      @image.fill(:green)
    end
    outline
    ladderize if @ladder
    super(screen)
  end
  
  ###
  # The rest are convenience methods, I guess
  
  def make_ladder
    @ladder = true
  end
  
  def sky?
    @sky
  end

  def dug?
    @dug
  end

  def ladder?
    @ladder
  end

  def to_s
    @x.to_s + ", " + @y.to_s
  end

end
