extends BaseScene


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if scene_manager.player:
		add_child(scene_manager.player)
		
	print(player.global_position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
