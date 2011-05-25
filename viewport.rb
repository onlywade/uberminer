class Viewport

	CENTER = (VIEWPORT_SIZE - 1) / 2

	def initialize(map, player)
		@map = map
		@player = player
	end
	
	def draw(screen)
		return unless @map.stale
		draw_map(screen)
		draw_player(screen)
	end
	
	def draw_map(screen)
		player_cell = @player.current_cell
		px = player_cell.x
		py = player_cell.y
		buffer = (VIEWPORT_SIZE - 1) / 2
		xrange = ((px - buffer)..(px + buffer))
		yrange = ((py - buffer)..(py + buffer))
		
		@map.draw_cell_range(xrange, yrange, screen)
	end
	
	def draw_player(screen)
		@player.set_center(:x => CENTER, :y => CENTER)
		@player.draw(screen)
	end

end