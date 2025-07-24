extends KinematicBody2D

onready var healthbar = $Healthbar
onready var _overbar = $Healthbar/overbar
onready var _underbar = $Healthbar/underbar
onready var _tween = $Healthbar/Tween
onready var health_visibility = $healthbar_visibility
onready var _anim = $AnimationPlayer
onready var body = $Sprite
onready var grave = $grave_disturbance/grave_shape
onready var hurtbox = $hurtbox/hurtbox_shape
onready var right_sight = $fov_right/fov_right_shape
onready var left_sight = $fov_left/fov_left_shape
onready var audio_zone = $audio_area/audio_shape
onready var combat_zone = $combat_zone/combat_zone_shape
onready var resume_chase = $resume_chase
onready var aggro = $aggro_timer
onready var give_up = $give_up
onready var attack_delay = $attack_delay

enum State {UNDERGROUND, RISE, RESTING, WAKE, LOOKING,
 IDLE, PATROLING, CHASING, JUMPING, DROPPING, LANDING,
 ATTACKING, DEATH}

var velocity = Vector2.ZERO
var gravity = 600
var normal_friction = 1000
var attack_friction = 800
var acceleration = 500
var walk_speed = 30
var run_speed = 60
var pause_duration = 999
var state
var max_health = 10
var health = 10
var damage = 10
var direction = 1
var aggro_time = 15
var attack_chain = [0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2]
var trevor = null
var setup = false

func setup():
	state = State.UNDERGROUND
	max_health(max_health)
	health_update(health)
	setup = true
	
func _physics_process(delta):
	if setup == false:
		setup()
	if state == State.DEATH || state == State.RESTING:
		apply_friction(delta, normal_friction)
	if state == State.PATROLING:
		if direction < 0:
			apply_acceleration(-1, delta, walk_speed)
		if direction > 0:
			apply_acceleration(1, delta, walk_speed)
	if state == State.CHASING:
		if trevor.position.x <= self.position.x + 10:
			direction = -1
			apply_acceleration(-1, delta, run_speed)
		if trevor.position.x >= self.position.x - 10:
			direction = 1
			apply_acceleration(1, delta, run_speed)
		if trevor.position.y > self.position.y + 100 || trevor.position.y < self.position.y - 100:
			state = State.IDLE
			velocity = Vector2.ZERO
	if state == State.ATTACKING:
		apply_friction(delta, normal_friction)
		if trevor.position.x < self.position.x:
			direction = -1
		if trevor.position.x > self.position.x:
			direction = 1
	if velocity.y > 40:
		state = State.DROPPING
	if state == State.DROPPING && velocity.y < 2:
		state = State.LANDING
	if state == State.LANDING:
		apply_friction(delta, normal_friction)
		if trevor != null:
			state = State.CHASING
		else:
			patrol()
	if not is_on_floor():
		apply_gravity(delta)
	else:
		velocity.y += 50 * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	play_animation(state, direction)

func Hit(damage):
	healthbar.visible = true
	health_visibility.start(10)
	health -= damage
	health_update(health)
	if health < 1:
		state = State.DEATH
		
func inch_forward():
	if direction < 0:
		self.position.x -= 5
	if direction > 0:
		self.position.x += 5
		
func health_update(health):
	_overbar.value = health
	_tween.interpolate_property(_underbar, "value", _underbar.value, health, 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0)
	_tween.start()
	
func max_health(max_health):
	_underbar.max_value = max_health
	_overbar.max_value = max_health
		
func _on_healthbar_visibility_timeout():
	healthbar.visible = false
		
func attack():
	aggro.stop()
	give_up.stop()
	if attack_delay.is_stopped():
		attack_delay.start(3)
		attack_chain.shuffle()
		if attack_chain[0] == 0:
			if direction < 0:
				_anim.play("left_attack_1")
			if direction > 0:
				_anim.play("right_attack_1")
		if attack_chain[0] == 1:
			if direction < 0:
				_anim.play("left_attack_2")
			if direction > 0:
				_anim.play("right_attack_2")
		if attack_chain[0] == 2:
			if direction < 0:
				_anim.play("left_combo")
			if direction > 0:
				_anim.play("right_combo")
		
func _on_hitbox_left_body_entered(body):
	body.Hit(damage)

func _on_hitbox_right_body_entered(body):
	body.Hit(damage)

func apply_friction(delta, friction_type):
	velocity.x = move_toward(velocity.x, 0, friction_type * delta)

func apply_acceleration(amount, delta, type):
	velocity.x = move_toward(velocity.x, type * amount, acceleration * delta)
	
func apply_gravity(delta):
	velocity.y += gravity * delta

func rest():
	state = State.RESTING
	
func patrol():
	state = State.PATROLING
	give_up.start(20)
	
func look_back():
	state = State.LOOKING
	
func remove_model():
	queue_free()
	
func _on_grave_disturbance_body_entered(body):
	state = State.RISE

func _on_fov_right_body_entered(body):
	trevor = body
	state = State.CHASING

func _on_fov_left_body_entered(body):
	trevor = body
	state = State.CHASING
	
func _on_combat_zone_body_entered(body):
	if direction < 0:
		_anim.play("left_idle")
	if direction > 0:
		_anim.play("right_idle")
	state = State.ATTACKING
	
func _on_combat_zone_body_exited(body):
	resume_chase.start(1)
	attack_delay.stop()
	
func _on_resume_chase_timeout():
	if trevor.position.x > self.position.x + 30 || trevor.position.x < self.position.x - 30:
		state = State.CHASING
		aggro.start(aggro_time)
	else:
		resume_chase.start(0.5)
		
func _on_aggro_timer_timeout():
	if state == State.CHASING:
		patrol()

func _on_give_up_timeout():
	rest()
	
func _on_audio_area_body_entered(body):
	state = State.WAKE

func play_animation(state, direction):
	match state:
		State.UNDERGROUND:
			body.visible = false
			grave.disabled = false
			hurtbox.disabled = true
			right_sight.disabled = true
			left_sight.disabled = true
			combat_zone.disabled = true
			audio_zone.disabled = true
			body.frame = 77
		State.RESTING:
			if direction < 0:
				_anim.play("left_resting")
			if direction > 0:
				_anim.play("right_resting")
		State.WAKE:
			if direction < 0:
				_anim.play("left_wake")
			if direction > 0:
				_anim.play("right_wake")
		State.LOOKING:
			if direction < 0:
				_anim.play("left_look_behind")
			if direction > 0:
				_anim.play("right_look_behind")
		State.RISE:
			body.visible = true
			if direction < 0:
				_anim.play("left_rise")
			if direction > 0:
				_anim.play("right_rise")
		State.PATROLING:
			if direction < 0:
				_anim.play("left_walk")
			if direction > 0:
				_anim.play("right_walk")
		State.CHASING:
			if direction < 0:
				_anim.play("left_run")
			if direction > 0:
				_anim.play("right_run")
		State.ATTACKING:
			attack()
		State.IDLE:
			if direction < 0:
				_anim.play("left_idle")
			if direction > 0:
				_anim.play("right_idle")
		State.JUMPING:
			if direction < 0:
				_anim.play("left_jumpoff")
				_anim.play("left_jump_loop")
			if direction > 0:
				_anim.play("right_jumpoff")
				_anim.play("right_jump_loop")
		State.DROPPING:
			if direction < 0:
				_anim.play("left_fall_loop")
			if direction > 0:
				_anim.play("right_fall_loop")
		State.LANDING:
			if direction < 0:
				_anim.play("left_landing")
			if direction > 0:
				_anim.play("right_landing")
		State.DEATH:
			if direction < 0:
				_anim.play("left_death")
			if direction > 0:
				_anim.play("right_death")

