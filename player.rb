require 'rubygems'
require 'rubygame'

include Rubygame

class Player
  include Sprites::Sprite
  include EventHandler::HasEventHandler
  
  FALL_SPEED = 10.0
  CELL_FALL_SPEED = 1000.0 / FALL_SPEED

  def initialize(game)
    # It's good to have a handle to the game instance, in case we want to see the clock or anything
    @game = game
    # The map, too. This is maybe bad?  But I like to be able to twiddle map cells based on things the player does.
    @map = @game.map
    # We'll just start out here.
    @x, @y = 0, 1
    
    # This is for convenience, really
    @current_cell = @map.cells_at[@x][@y]
    
    # A temporary hack to make sure the player starts in an empty cell
    @current_cell.dug = true
    
    # We'll use a boring rectangle for the surface, for now
    @image = Surface.new([CELL_SIZE - 2, CELL_SIZE - 2])
    @image.fill(:yellow)
    
    # The Rect is actually how we control the position of the surface
    @rect = @image.make_rect
    
    # Some state tracking bits here
    @falling = false
    @falling_timer = nil
    
    # Put the dude in his starting cell
    set_center

    # Wire up any KeyPressed events to the #key_pressed method
    make_magic_hooks(KeyPressed => :key_pressed)
  end
  
  # This method will get called once per game step, in case we want to do time based operations
  # that aren't based on keyboard input.
  def update(time_since_tick)
    fall_more(time_since_tick) if @falling #keep falling if there is no ground beneath our feet
  end
  
  private

  # This method will position the guy into whatever cell he's supposed to be in (@x,@y)
  def set_center
    xpos = @x * CELL_SIZE + (CELL_SIZE / 2)
    ypos = @y * CELL_SIZE + (CELL_SIZE / 2)
    @rect.center = [xpos, ypos]
  end
  
  # This just updates our current_cell convenvience variable
  def set_current_cell
    @current_cell = @map.cells_at[@x][@y]
  end

  # If we get a direction key, just try to move that way.
  # If space bar, build a fuckin' ladder and climb it.
  def key_pressed(event)
    case event.key
      when :left
        update_position :left
      when :right
        update_position :right
      when :up
        update_position :up
      when :down
        update_position :down
      when :space
        build_ladder
    end
  end
  
  # This method tries to move in the direction specified.
  def update_position(direction)
    ox, oy = @x, @y
    nx, ny = @x, @y
    case direction
      when :left
        nx -= 1
      when :right
        nx += 1
      when :up
        return unless @current_cell.ladder? && !@current_cell.sky?
        ny -= 1
      when :down
        ny += 1
    end
    
    # If the would-be destination isn't valid, just return without doing anything
    return if @map.cells_at[nx][ny].rock
    return unless ((0..MAP_SIZE - 1).include?(nx) && (0..MAP_SIZE - 1).include?(ny))
    
    # If we've made it this far, the move is valid.  Update player's cell coords now.
    @x, @y = nx, ny
    set_center
    set_current_cell
    
    # Fire some events at the map, so it knows how to redraw things the next time around
    @map.handle(CellDugEvent.new([nx, ny])) unless @map.cells_at[nx][ny].dug? or @map.cells_at[nx][ny].sky?
    @map.handle(PlayerMovedEvent.new([ox, oy]))

    # Decide whether this move put the player in gravitational jeopardy
    @falling = true if @map.cells_at[nx][ny + 1].dug? && !@map.cells_at[nx][ny + 1].ladder?
  end
  
  # So each time the game loops, if there is nothing below the player's feet, he should fall.
  # This method does the actual falling (updating y coord), taking into consideration the 
  # game timing, target fall speed, etc.
  def fall_more(time_since_tick)
    
    # Check to see if we've hit ground yet
    cell_below = @map.cells_at[@x][@y + 1]
    if cell_below.dug? && !cell_below.ladder?
      
      # I use this timer to decide when it's time for the guy to drop a cell.
      # Basically the idea is to drop 1 cell every X miliseconds, to acheive 
      # an ultimate speed of Y cells per second.
      @falling_timer ||= 0
      @falling_timer += time_since_tick
      puts "falling_timer: #{@falling_timer}"
      
      if @falling_timer >= CELL_FALL_SPEED
        # Time to fall
        @y += 1
        set_center
        set_current_cell
        @map.handle(PlayerMovedEvent.new([@x,@y - 1])) #tell the map about the movement so it can redraw
        @falling_timer = nil #reset the falling timer for the next drop.
      end
      
    else
      @falling = false # we're done falling if we've hit ground
    end
  end
  
  # Turn the current_cell into a ladder cell, and try to climb up it.
  def build_ladder
    return if @current_cell.sky? #building a ladder topside is not allowed.
    puts "building ladder"
    @current_cell.make_ladder #this just set's the cells' @ladder attribute to true
    update_position(:up)
  end

end