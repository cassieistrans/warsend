extends Node2D

var x = 1020
var y = 750

func _on_Area2D_area_entered(area):
	if area.is_in_group("trevor"):
		if QuickSave.spawnx != x:
			QuickSave.spawnx = x
			QuickSave.spawny = y
		get_tree().reload_current_scene()
