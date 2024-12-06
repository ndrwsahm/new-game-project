class_name SceneTrigger extends Area2D

@export var connected_scene: String #scene to change to

func _on_body_entered(body) -> void:
	if body is Player:
		scene_manager.change_scene(get_owner(), connected_scene)
