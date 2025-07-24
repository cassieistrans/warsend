extends Node2D

const dash_delay = 0.4

onready var trevor = get_parent()
onready var timer = $Timer
onready var _reset_timer = $ResetTimer
onready var ghost_timer = $GhostTimer
onready var dust = $Position2D/dust

var ghost_scene = preload("res://Scenes/DashGhost.tscn")

func dash(duration):
	timer.wait_time = duration
	timer.start()
	ghost_timer.start()
	instance_ghost()
	dust.position.y = 30
	dust.restart()
	dust.emitting = true

func instance_ghost():
	var ghost: Sprite = ghost_scene.instance()
	get_parent().get_parent().get_parent().add_child(ghost)
	if $Position2D.scale.x > 0:
		ghost.global_position.y = global_position.y
		ghost.global_position.x = global_position.x - 17
	if $Position2D.scale.x < 0:
		ghost.global_position.y = global_position.y
		ghost.global_position.x = global_position.x + 17
	ghost.scale.x = $Position2D.scale.x

func dashing():
	return !timer.is_stopped()

func _on_GhostTimer_timeout() -> void:
	instance_ghost()

func _on_Timer_timeout():
	ghost_timer.stop()
	trevor.stop_dash()

func set_pos(direction):
	if direction == 0:
		$Position2D.scale.x = 1
	if direction == 1:
		$Position2D.scale.x = -1

