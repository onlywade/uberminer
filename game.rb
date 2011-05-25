require 'rubygems'
require 'rubygame'

require 'config'
require 'map'
require 'player'
require 'viewport'

include Rubygame
include Rubygame::Events
include Rubygame::EventActions
include Rubygame::EventTriggers

class Game
  include EventHandler::HasEventHandler
  
  attr_reader :map, :clock

  def initialize
    make_screen
    make_queue
    make_clock
    make_event_hooks
    make_map
    make_player
		make_viewport
		draw_viewport
  end

  def go
    catch(:quit) do
      loop do
        step
      end
    end
  end

  private

  def make_screen
    @screen = Screen.open(SCREEN_SIZE)
  end

  def make_queue
    @queue = EventQueue.new
    @queue.enable_new_style_events
    @queue.ignore = [MouseMoved]
  end

  def make_clock
    @clock = Clock.new
    @clock.target_framerate = TARGET_FRAMERATE
    @clock.calibrate
  end

  def make_event_hooks
    hooks = {
      :escape => :quit,
      :q => :quit,
      QuitRequested => :quit
    }
    make_magic_hooks(hooks)
  end

  def make_map
    @map = Map.new
  end

  def draw_map
    @map.draw(@screen)
  end

  def draw_map_changes
    @map.draw_changes(@screen)
  end

  def clear_map_changes
    @map.clear_changes
  end

  def make_player
    @player = Player.new(self)
    make_magic_hooks_for(@player, {YesTrigger.new => :handle})
  end
  
  def update_player(time_since_tick)
    @player.update(time_since_tick)
  end

  def draw_player
    @player.draw(@screen)
  end
	
	def make_viewport
		@viewport = Viewport.new(@map, @player)
	end
	
	def draw_viewport
		@viewport.draw(@screen)
	end
  
  def step
    dt = @clock.tick
    @queue.each { |event| handle(event) }
    update_player(dt)
		draw_viewport
    @screen.update
  end

  def quit
    puts "Quitting."
    throw :quit
  end

end

Game.new.go
Rubygame.quit
