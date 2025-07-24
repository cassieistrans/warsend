extends KinematicBody2D

signal _add_item(item_id)

onready var _sprite = $Sprite
onready var _particles = $CPUParticles2D
onready var velocity = Vector2.ZERO
const gravity = 9.3

var setup = false

func setup():
	_particles.emitting = true
	setup = true

func _physics_process(delta):
	if setup == false:
		setup()
	if is_on_floor():
		velocity.y = gravity
	else:
		velocity.y += gravity
	move_and_slide(velocity, Vector2.UP)

func Hit(dmg):
	emit_signal("_add_item", 2001)
	queue_free()
