extends Node2D

onready var _over_bar = $over_bar
onready var _under_bar = $under_bar
onready var _tween = $Tween

func health_update(health):
	_over_bar.value = health
	_tween.interpolate_property(_under_bar, "value", _under_bar.value, health, 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0)
	_tween.start()
	
func max_health(max_health):
	_under_bar.max_value = max_health
	_over_bar.max_value = max_health
