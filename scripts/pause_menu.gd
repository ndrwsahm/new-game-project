extends CanvasLayer

@onready var menu = $Menu

func _ready():
	menu.close()
	
func _input(event):
	if event.is_action_pressed("select"):
		if menu.isOpen:
			menu.close()
		else:
			menu.open()
