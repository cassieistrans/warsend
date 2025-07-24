extends Label

signal _heal()

onready var _empty = preload("res://Assets/UI/vial.png")
onready var _trevor = preload("res://Scenes/Trevor.tscn")
onready var current_potions = 0

func _ready():
	self.set_text(str(current_potions))
	var dynamic_font = DynamicFont.new()
	dynamic_font.font_data = load("res://font.ttf")
	dynamic_font.size = 10
	self.set("custom_fonts/font", dynamic_font)

func set_potions(potions):
	current_potions += potions
	self.set_text(str(current_potions))

func _on_heal_pressed():
	if current_potions > 0:
		current_potions -= 1
		self.set_text(str(current_potions))
		emit_signal("_heal")
	
