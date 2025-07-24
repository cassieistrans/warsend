extends CanvasLayer

onready var _menu = $main_menu

func _ready():
	_menu.close_menu()
	
func _input(event):
	if event.is_action_pressed("ui_menu"):
		if _menu.open == true:
			_menu.close_menu()
		else:
			_menu.open_menu()
