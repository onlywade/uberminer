# This is an event that can be sent to a Map instance when a cell has been dug.
class CellDugEvent
  attr_reader :cell_coords

  def initialize(cell_coords)
    @cell_coords = cell_coords #coords of the cell that was dug
  end
end

# This one can be sent to a Map instance when a player has moved.
class PlayerMovedEvent
  attr_reader :cell_coords

  def initialize(cell_coords)
    @cell_coords = cell_coords # coords of the cell that was _vacated_
  end
end