extends Label

onready var current_gold = 0

func _ready():
	self.set_text(str(current_gold))
	var dynamic_font = DynamicFont.new()
	dynamic_font.font_data = load("res://font.ttf")
	dynamic_font.size = 10
	self.set("custom_fonts/font", dynamic_font)

func update_gold(new_gold):
	current_gold += new_gold
	self.set_text(str(current_gold))
