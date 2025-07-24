extends Node2D

onready var _overbar = $overbar
onready var _underbar = $underbar
onready var _tween = $Tween

func stamina_update(stamina):
	_overbar.value = stamina
	_tween.interpolate_property(_underbar, "value", _underbar.value, stamina, 0.1, Tween.TRANS_SINE, Tween.EASE_OUT_IN, 0)
	_tween.start()
	
func max_stamina(max_stamina):
	_underbar.max_value = max_stamina
	_overbar.max_value = max_stamina
