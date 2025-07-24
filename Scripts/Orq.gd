extends KinematicBody2D

onready var _animation_player = $AnimationPlayer
onready var sprite = $Sprite

enum {
	IDLE,
	DIR,
	MOVE
}

var health = 14
const speed = 20
var state = MOVE
var dir = Vector2.LEFT

func _ready():
	randomize()

func _process(delta):
	if health < 0:
		queue_free()
	match state:
		IDLE:
			_animation_player.play("idle")
			
		DIR:
			dir = choose([Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN])
			state = choose([IDLE, MOVE])
			
		MOVE:
			_animation_player.play("run")
			move(delta)
			
	if dir == Vector2.RIGHT:
		$Sprite.flip_h = false
	else:
		$Sprite.flip_h = true
		
func move(delta):
	position += move_and_slide(dir * speed * delta)
	
func choose(array):
	array.shuffle()
	return array.front()
	
func _on_Timer_timeout():
	$Timer.wait_time = choose([0.5, 1, 1.5])
	state = choose([IDLE, DIR, MOVE])


func Hit(damage):
	health -= damage
	print(health)
	print(damage)
	
