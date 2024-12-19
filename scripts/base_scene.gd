class_name BaseScene extends Node

@onready var player: Player = $Player
@onready var entrance_markers: Node2D = $EntranceMarkers

var tree

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tree = get_tree()
	if scene_manager.player:
		if player:
			player.queue_free()
			
		player = scene_manager.player
		add_child(player)
		
	var current_scene = scene_manager.current_scene_name
	
	if current_scene == "battle" or current_scene == "volcano_battle" or current_scene == "forest_battle":
		player.visible = false
	else:
		player.visible = true
		
	position_player()

func position_player() -> void:
	var last_scene = scene_manager.last_scene_name.to_lower().replace('_', '').replace(' ', '')
	
	if last_scene.is_empty():
		last_scene = "any"
		
	for entrance in entrance_markers.get_children():
		var entrance_name = entrance.name.to_lower().replace('_', '').replace(' ', '')
		
		if entrance is Marker2D and entrance_name == "any" or entrance_name == last_scene:
			player.global_position = entrance.global_position

#Need to key for each scene!!!!
func _on_menu_closed() -> void:
	if !tree:
		return
	tree.paused = false
	
#Need to key for each scene!!!!
func _on_menu_opened() -> void:
	if !tree:
		return
	tree.paused = true
