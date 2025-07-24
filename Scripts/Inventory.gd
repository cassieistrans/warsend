extends Control

var open: bool = false

func open_menu():
	self.visible = true
	open = true
	
func close_menu():
	self.visible = false
	open = false
