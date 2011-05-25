require 'rubygems'
require 'rubygame'

require 'cell'
require 'custom_events'

include Rubygame

# This class will contain our map, which is made up of an array of Cell instances
class Map
  include EventHandler::HasEventHandler
  attr_reader :cells, :cells_at, :stale

  def initialize
    @cells = [] # store all cells for easy loop access
    @cells_at = [] # store all cells for easy coord access
    @updated_cells = [] # store cells that should be redrawn during the next step
		@stale = true

    # Populate the array of cells based on defined map size
    (0..MAP_SIZE[0] - 1).each do |x|
      @cells_at[x] = []
      (0..MAP_SIZE[1] - 1).each do |y|
        @cells << @cells_at[x][y] = Cell.new([x,y])
      end
    end
    
    # This line just "forwards" events to the appropriate method
    make_magic_hooks(CellDugEvent => :cell_dug, PlayerMovedEvent => :player_moved)
    
    # Build a 2 cell high "above ground" area at the top of the map.
    # Note: The player may not build ladders up here.  Also, this is where the shops will be.  :)
    make_above_ground
    
    # Populate the map with some scattered boulders, which cannot be dug through or anything.
    # TODO: give rocks gravity, so they smash a players head if he tunnels directly underneath one.
    make_some_random_rocks
  end
	
	def cell_at(xcoord, ycoord)
		if ((0..MAP_SIZE[0] - 1).include?(xcoord) && (0..MAP_SIZE[1] - 1).include?(ycoord))
			return @cells_at[xcoord][ycoord]
		else
			return Cell.new([xcoord, ycoord], :type => :oom)
		end
	end
  
  # I'm just setting @sky to true on the cells I deem to be worthy of above-ground-ness
  def make_above_ground
    (0..MAP_SIZE[0] - 1).each do |x|
      (0..1).each do |y|
        @cells_at[x][y].sky = true
      end
    end
  end
  
  # Method to make random rocks
  def make_some_random_rocks
    count = 5 + rand(10) # somewhere from 5-15 rocks will do, i guess
    count.times do
      x = rand(MAP_SIZE[0] - 1)
      y = rand(MAP_SIZE[1] - 3) + 2 # being careful not to put rocks above ground!
      puts "making rock at: #{x}, #{y}"
      @cells_at[x][y].rock = true
    end
  end 
  
  # If Map receives a CellDug event, it marks the appropriate cell as dug.
  def cell_dug(event)
    target_cell = @cells_at[event.cell_coords[0]][event.cell_coords[1]]
    puts "Digging cell: " + target_cell.to_s
    target_cell.dug = true
  end
  
  # If it gets a PlayerMoved event, it puts the vacated cell into the @updated_cells list,
  # so that the cell will be redrawn (to erase the player) on the next loop.
  # TODO: see if it would be smarter to do something like Player#undraw instead
  def player_moved(event)
    vacated_cell = @cells_at[event.cell_coords[0]][event.cell_coords[1]]
    @updated_cells << vacated_cell
		@stale = true
  end
  
  # Note that Map doesn't include Sprite, so it doesn't have it's own #draw method.
  # Instead I delegate all of the drawing to the cells, which can draw themselves where they belong
  def draw(screen)
    @cells.each { |cell| cell.draw(screen) }
  end
	
	def draw_cell_range(xrange, yrange, screen)	
		xrange.each_with_index do |xcoord, xindex|
			yrange.each_with_index do |ycoord, yindex|
				cell_at(xcoord, ycoord).draw(screen, :x => xindex, :y => yindex)
			end
		end
		@stale = false
	end
	
  # Sometimes I only want to draw the cells that have changed in some way, to save precious screen-drawing-overhead-time-stuff
  def draw_changes(screen)
    @updated_cells.each { |cell| cell.draw(screen) }
    @updated_cells.clear
  end

end
