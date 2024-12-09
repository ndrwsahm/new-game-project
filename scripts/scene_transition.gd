extends CanvasLayer
@onready var color_rect: ColorRect = $ColorRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	color_rect.visible = false
	
func load_scene():
	
	animation_player.play("Fade")
	await animation_player.animation_finished

func fade_scene():
	animation_player.play_backwards("Fade")
	await animation_player.animation_finished
