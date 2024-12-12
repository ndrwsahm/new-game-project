## Represents and manages the game board. Stores references to entities that are in each cell and
## tells whether cells are occupied or not.
## Units can only move around the grid one at a time.
class_name GameBoard
extends Node2D

const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
const DIAGANOL_DIRECTIONS = [Vector2.LEFT+Vector2.UP, Vector2.RIGHT+Vector2.UP,
							Vector2.LEFT+Vector2.DOWN,	Vector2.RIGHT+Vector2.DOWN]
## Resource of type Grid.
@export var grid: Resource = preload("res://resources/Grid.tres")

## Mapping of coordinates of a cell to a reference to the unit it contains.
var _units := {}
var _active_unit: Unit
var _walkable_cells := []

@onready var _unit_overlay: UnitOverlay = $UnitOverlay
@onready var _unit_path: UnitPath = $UnitPath


func _ready() -> void:
	_reinitialize()

func _unhandled_input(event: InputEvent) -> void:
	if _active_unit and event.is_action_pressed("cancel_action"):
		_deselect_active_unit()
		_clear_active_unit()


func _get_configuration_warning() -> String:
	var warning := ""
	if not grid:
		warning = "You need a Grid resource for this node to work."
	return warning


## Returns `true` if the cell is occupied by a unit.
func is_occupied(cell: Vector2) -> bool:
	return _units.has(cell)

## Returns an array of cells a given unit can walk using the flood fill algorithm.
func get_walkable_cells(unit: Unit) -> Array:
	var array := []
	if unit.class_type == "golem":
		return _golem_fill(unit.cell, unit.move_range)
	elif unit.class_type == "familiar":
		return _familiar_fill(unit.cell, unit.move_range)
	else:
		return _summoner_fill(unit.cell, unit.move_range)
## Clears, and refills the `_units` dictionary with game objects that are on the board.
func _reinitialize() -> void:
	_units.clear()

	for child in get_children():
		var unit := child as Unit
		if not unit:
			continue
		_units[unit.cell] = unit
		
func _summoner_fill(cell: Vector2, max_distance: int) -> Array:
	print("current position: ", cell.x, cell.y)
	var moves := [
		Vector2(cell.x+1, cell.y-2),
		Vector2(cell.x+1, cell.y+2),
		Vector2(cell.x+2, cell.y-1),
		Vector2(cell.x+2, cell.y+1),
		
		Vector2(cell.x-1, cell.y-2),
		Vector2(cell.x-1, cell.y+2),
		Vector2(cell.x-2, cell.y-1),
		Vector2(cell.x-2, cell.y+1)
	]
	var array := []

	for m in moves:
		if is_occupied(m):
			continue
		if not grid.is_within_bounds(m):
			continue 
		array.append(m)
			#remove from list
	print(array)		
	return array

func _familiar_fill(cell: Vector2, max_distance: int) -> Array:
	var array := []

	for m in range(max_distance):
		var down_right := Vector2(cell.x+m+1, cell.y+m+1)
		if is_occupied(down_right):
			break
		if grid.is_within_bounds(down_right):
			array.append(down_right)
	
	for m in range(max_distance):	
		var up_right := Vector2(cell.x+m+1, cell.y-m-1)
		if is_occupied(up_right):
			break
		if grid.is_within_bounds(up_right):
			array.append(up_right)
			
	for m in range(max_distance):		
		var down_left := Vector2(cell.x-m-1, cell.y+m+1)
		if is_occupied(down_left):
			break
		if grid.is_within_bounds(down_left):
			array.append(down_left)

	for m in range(max_distance):	
		var up_left := Vector2(cell.x-m-1, cell.y-m-1)
		if is_occupied(up_left):
			break
		if grid.is_within_bounds(up_left):
			array.append(up_left)
			
	return array
## Returns an array with all the coordinates of walkable cells based on the `max_distance`.
func _golem_fill(cell: Vector2, max_distance: int) -> Array:
	var array := []
	var stack := [cell]
	
	while not stack.size() == 0:
		var current = stack.pop_back()
		
		if not grid.is_within_bounds(current):
			continue
		if current in array:
			continue
		if current.x - cell.x != 0 and current.y - cell.y != 0:
			continue
			
		var difference: Vector2 = (current - cell).abs()
		var distance := int(difference.x + difference.y)

		if distance > max_distance:
			continue

		array.append(current)
		
		for direction in DIRECTIONS:
			var coordinates: Vector2 = current + direction
			if is_occupied(coordinates):
				continue
			if coordinates in array:
				continue
			# Minor optimization: If this neighbor is already queued
			#	to be checked, we don't need to queue it again
			if coordinates in stack:
				continue

			stack.append(coordinates)
			
	return array

func _teleport_active_units(new_cell: Vector2) -> void:
	if is_occupied(new_cell) or not new_cell in _walkable_cells:
		return
	# warning-ignore:return_value_discarded
	_units.erase(_active_unit.cell)
	_units[new_cell] = _active_unit
	_deselect_active_unit()
	_active_unit.teleport(new_cell)
	_clear_active_unit()
	#emit_signal("walk_finished")
	#await _active_unit.walk_finished
	print("walk finished")
	
	
## Updates the _units dictionary with the target position for the unit and asks the _active_unit to walk to it.
func _move_active_unit(new_cell: Vector2) -> void:
	if is_occupied(new_cell) or not new_cell in _walkable_cells:
		return
	# warning-ignore:return_value_discarded
	_units.erase(_active_unit.cell)
	_units[new_cell] = _active_unit
	_deselect_active_unit()
	_active_unit.walk_along(_unit_path.current_path)
	await _active_unit.walk_finished
	_clear_active_unit()

## Selects the unit in the `cell` if there's one there.
## Sets it as the `_active_unit` and draws its walkable cells and interactive move path. 
func _select_unit(cell: Vector2) -> void:
	if not _units.has(cell):
		return

	_active_unit = _units[cell]
	_active_unit.is_selected = true
	_walkable_cells = get_walkable_cells(_active_unit)
	_unit_overlay.draw(_walkable_cells)
	_unit_path.initialize(_walkable_cells)


## Deselects the active unit, clearing the cells overlay and interactive path drawing.
func _deselect_active_unit() -> void:
	_active_unit.is_selected = false
	_unit_overlay.clear()
	_unit_path.stop()


## Clears the reference to the _active_unit and the corresponding walkable cells.
func _clear_active_unit() -> void:
	_active_unit = null
	_walkable_cells.clear()

func _on_cursor_accept_pressed(cell: Variant) -> void:
	if not _active_unit:
		_select_unit(cell)
	elif _active_unit.is_selected:
		if _active_unit.class_type == "summoner":
			_teleport_active_units(cell)
			#_move_active_unit(cell)
			
		else:
			_move_active_unit(cell)

func _on_cursor_moved(new_cell: Variant) -> void:
	if _active_unit and _active_unit.is_selected:
		_unit_path.draw(_active_unit.cell, new_cell)
