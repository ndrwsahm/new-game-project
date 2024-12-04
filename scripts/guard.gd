extends Area2D

var is_chatting = false


func _on_body_entered(body: Node2D) -> void:
	pass
	
func _on_dialogue_dialog_finished() -> void:
	is_chatting = false
	
func _on_chat_detection_area_body_entered(body: Node2D) -> void:
	print("Player collide")
	$Dialog.start()

func _on_chat_detection_area_body_exited(body: Node2D) -> void:
	$Dialog.end()
