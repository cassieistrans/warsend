extends KinematicBody2D

# Engine components
onready var edge = $edge
onready var wall = $wall
onready var Trevor = $Trevor_detector
onready var Attack = $Attack_area
onready var _anim = $AnimationPlayer
onready var sprite = $Sprite

# New State Machine
enum {IDLE, PATROLING, CHASING, ATTACKING, DROPPING, LANDING, KNOCKDOWN, STANDING}
enum Direction {LEFT, RIGHT}

var velocity = Vector2.ZERO
var gravity = 600
var normal_friction = 10000
var attack_friction = 8000
var acceleration = 500
var walk_speed = 30
var run_speed = 60

var state = PATROLING
var direction = Direction.LEFT
var can_attack = true

var max_health = 10
var health = 10

func _physics_process(delta):
	if Trevor.is_colliding():
		state = CHASING
		if direction == Direction.LEFT:
			apply_acceleration(-1, delta, run_speed)
			sprite.hframes = 6
			_anim.play("L_run")
		if direction == Direction.RIGHT:
			apply_acceleration(1, delta, run_speed)
			sprite.hframes = 6
			_anim.play("R_run")
	if !Trevor.is_colliding() && state == CHASING:
			state = PATROLING
	if !Trevor.is_colliding() && edge.is_colliding() && state == PATROLING:
		if direction == Direction.LEFT:
			apply_acceleration(-1, delta, walk_speed)
			sprite.hframes = 4
			_anim.play("L_walk")
		if direction == Direction.RIGHT:
			apply_acceleration(1, delta, walk_speed)
			sprite.hframes = 4
			_anim.play("R_walk")
	if !edge.is_colliding() && state != CHASING || wall.is_colliding() && state != CHASING:
		if direction == Direction.LEFT:
			direction = Direction.RIGHT
			apply_acceleration(1, delta, walk_speed)
			sprite.hframes = 4
			_anim.play("R_walk")
		else:
			direction = Direction.LEFT
			apply_acceleration(-1, delta, walk_speed)
			sprite.hframes = 4
			_anim.play("L_walk")
	if not is_on_floor():
		apply_gravity(delta)
	else:
		velocity.y += 50 * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	
func Hit(damage):
	health -= damage
	print(health)
	if health < 1:
		queue_free()

func apply_friction(delta, friction_type):
	velocity.x = move_toward(velocity.x, 0, friction_type * delta)

func apply_acceleration(amount, delta, type):
	velocity.x = move_toward(velocity.x, type * amount, acceleration * delta)
	
func apply_gravity(delta):
	velocity.y += gravity * delta
