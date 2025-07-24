extends Label

func _ready():
	var dynamic_font = DynamicFont.new()
	dynamic_font.font_data = load("res://font.ttf")
	dynamic_font.size = 10
	self.set("custom_fonts/font", dynamic_font)
