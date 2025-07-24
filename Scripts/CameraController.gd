extends Camera2D

var pos = Vector2.ZERO

func _physics_process(_delta):
	position = pos
	
func cam_pos(position):
	pos = position
