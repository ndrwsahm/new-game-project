class_name Player extends CharacterBody2D

const SPEED = 225.0
const TILESIZE = 64

const PUSH_FORCE = 75
const MAX_VELOCITY = 75

var is_frozen = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var door_ray = $DoorRayCast2D

func _physics_process(delta: float) -> void:
	if is_frozen:
		return 
		
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "right"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y > 0:
		$AnimatedSprite2D.animation = "down"
	elif velocity.y < 0:
		$AnimatedSprite2D.animation = "up"
	elif velocity.y == 0 and velocity.x == 0:
		$AnimatedSprite2D.animation = "idle"
		
	velocity = direction * SPEED
	
	move_and_slide()
	
func freeze_player():
	is_frozen = true
	
func unfreeze_player():
	is_frozen = false
