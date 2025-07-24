extends KinematicBody2D

# Signals
signal _health_changed(health)
signal _max_health(health)
signal _gold_increased(gold)
signal _ring(ring)
signal _max_potions(potions)
signal _stamina_changed(stamina)
signal _max_stamina(stamina)

# Engine components
onready var _cam = get_parent().get_node("Camera2D")
onready var equipment = preload("res://Scripts/Equipmment.gd")
onready var dash = $Dash
onready var _anim = $AnimationPlayer
onready var weapon_sprite = $weapon
onready var chest_sprite = $chest
onready var head_sprite = $head
onready var right_arm = $r_arm
onready var right_hand = $r_hand
onready var left_arm = $l_arm
onready var left_hand = $l_hand
onready var thighs = $thighs
onready var feet = $feet

# State Machine
enum State {IDLE, ATTACKING, COMBO, RUNNING, JUMPING, DROPPING,
 LANDING, DASHING, KNOCKDOWN, STANDING, DEATH}

# Movement Values
var velocity = Vector2.ZERO
var gravity = 600
var standard_gravity = 50
var normal_friction = 800
var dash_friction = 600
var landing_friction = 750
var acceleration = 500
var dash_speed = 600
var dash_duration = 0.1
var speed = 150
var jump_force = -250
var cut_jump = -65
var cut_count = 0

# Control values
var setup = false
var direction = 1
var state
var pause_duration = 999
var advance_attack = false

# Player Stats
var level = 1
var current_stamina = 200
var max_stamina = 200
var stamina_regen_rate = 0.7
var attack_cost = 140
var dash_cost = 180
var max_health = 30
var health = 30

func setup():
	if setup == false:
		emit_signal("_max_health", max_health)
		emit_signal("_health_changed", health)
		emit_signal("_gold_increased", QuickSave.gold)
		emit_signal("_max_stamina", max_stamina)
		emit_signal("_stamina_changed", current_stamina)
		emit_signal("_max_potions", QuickSave.potions)
		set_equipment(2000)
		setup = true

func _physics_process(delta):
	_cam.cam_pos(self.position)
	if setup == false:
		setup()
	if state != State.DEATH:

#STAMINA REGEN
		if state != State.ATTACKING || state != State.COMBO || state != State.DASHING:
			stamina_regen()
		
#ATTACK
		if current_stamina > attack_cost:
			if Input.is_action_just_pressed("ui_atk") && is_on_floor() && advance_attack == false:
				stamina_usage(attack_cost)
				state = State.ATTACKING
			if Input.is_action_just_pressed("ui_atk") && advance_attack == true:
				stamina_usage(attack_cost)
				state = State.COMBO
			
#DASH
		if current_stamina > dash_cost:
			if Input.is_action_just_pressed("ui_dash") && is_on_floor():
				state = State.DASHING
				if direction == 1:
					stamina_usage(dash_cost)
					dash.set_pos(0)
					dash.dash(dash_duration)
					velocity.x = dash_speed
				if direction == -1:
					stamina_usage(dash_cost)
					dash.set_pos(1)
					dash.dash(dash_duration)
					velocity.x = -dash_speed
					
#MOVEMENT
		if state != State.ATTACKING:
			if Input.is_action_pressed("ui_left"):
				direction = -1
				apply_acceleration(-1, delta)
				if state == State.IDLE:
					state = State.RUNNING
			if Input.is_action_pressed("ui_right"):
				direction = 1
				apply_acceleration(1, delta)
				if state == State.IDLE:
					state = State.RUNNING
			if Input.is_action_just_released("ui_left"):
				state = State.IDLE
			if Input.is_action_just_released("ui_right"):
				state = State.IDLE
			
#JUMP

		if Input.is_action_just_pressed("ui_jump") && is_on_floor():
			jump()
			state = State.JUMPING
		if Input.is_action_just_released("ui_jump") && !is_on_floor()  && velocity.y < 10:
			jump_cut(1)
		if velocity.y > 1:
			state = State.DROPPING
		if state == State.DROPPING && velocity.y < 2:
			state = State.LANDING
			cut_count = 0
		if state == State.LANDING:
			pause(30)
			apply_friction(delta, landing_friction)
			
#GRAVITY AND FRICTION

		if state == State.IDLE or state == State.ATTACKING or state == State.COMBO:
			apply_friction(delta, normal_friction)
	if not is_on_floor():
		apply_gravity(delta)
	else:
		velocity.y += standard_gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	play_animation(state, direction)

func apply_friction(delta, friction_type):
	velocity.x = move_toward(velocity.x, 0, friction_type * delta)

func apply_acceleration(amount, delta):
	velocity.x = move_toward(velocity.x, speed * amount, acceleration * delta)
	
func apply_gravity(delta):
	velocity.y += gravity * delta
	
func jump():
	velocity.y += jump_force
	
func jump_cut(count):
	if cut_count == 0:
		velocity.y = cut_jump
		cut_count += count
	
func stamina_regen():
	if current_stamina < max_stamina:
		current_stamina += stamina_regen_rate
		emit_signal("_stamina_changed", current_stamina)
	
func stamina_usage(amount):
	current_stamina -= amount
	emit_signal("_stamina_changed", current_stamina)
	
func stop_dash():
	state = State.IDLE
	velocity.x = move_toward(velocity.x, 0, dash_friction)
	
func combo_available():
	advance_attack = true

func end_attack():
	advance_attack = false
	state = State.IDLE

func Hit(damage):
	health -= damage
	emit_signal("_health_changed", health)
	if health < 1:
		state = State.DEATH
		velocity = Vector2.ZERO
		
func heal():
	#fix this
	health += 10
	emit_signal("_health_changed", health)
		
func remove_model():
	queue_free()
	get_tree().reload_current_scene()
	
func set_equipment(id):
	if equipment.item_id.has(id):
		head_sprite.texture = equipment.item_id.get(id)
	
func _on_broadsword_hb_r_area_entered(area):
	area.get_parent().Hit(8)

func _on_broadsword_hb_l_area_entered(area):
	area.get_parent().Hit(8)

func pause(duration):
	if pause_duration == 999:
		pause_duration = duration
	if pause_duration > 0 && pause_duration < 100:
		pause_duration -= 1
	if pause_duration == 0:
		state = State.IDLE
		pause_duration = 999
	
func play_animation(state, direction):
	match state:
		State.IDLE:
			if direction < 0:
				_anim.play("left_idle_1")
			if direction > 0:
				_anim.play("right_idle_1")
		State.RUNNING:
			if direction < 0:
				_anim.play("left_run")
			if direction > 0:
				_anim.play("right_run")
		State.ATTACKING:
			if direction < 0:
				_anim.play("left_attack_1")
			if direction > 0:
				_anim.play("right_attack_1")
		State.COMBO:
			if direction < 0:
				_anim.play("left_attack_2")
			if direction > 0:
				_anim.play("right_attack_2")
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
		State.KNOCKDOWN:
			if direction < 0:
				_anim.play("left_knockdown")
			if direction > 0:
				_anim.play("right_knockdown")
		State.STANDING:
			if direction < 0:
				_anim.play("left_standup")
			if direction > 0:
				_anim.play("right_standup")
		State.DEATH:
			if direction < 0:
				_anim.play("left_death")
			if direction > 0:
				_anim.play("right_death")

