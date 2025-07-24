extends Sprite

onready var _lightboots = preload("res://Assets/UI/Skills/lightboot_skill.png")
onready var _rose = preload("res://Assets/UI/Skills/thorns.png")
onready var _ember = preload("res://Assets/UI/Skills/fireball.png")
onready var _haste = preload("res://Assets/UI/Skills/speed_up.png")
onready var _energy = preload("res://Assets/UI/Skills/energy_up.png")
onready var _brent = preload("res://Assets/UI/Skills/def_up.png")
onready var _cliff = preload("res://Assets/UI/Skills/atk_up.png")
onready var _turn_undead = preload("res://Assets/UI/Skills/turn_undead.png")
onready var _opal = preload("res://Assets/UI/Skills/regen.png")
onready var _gold = preload("res://Assets/UI/Skills/gold_up.png")

func set_skill(skill):
	if skill == "lightboots":
		self.texture = _lightboots
	if skill == "energy":
		self.texture = _energy
	if skill == "rose_ring":
		self.texture = _rose
	if skill == "ember":
		self.texture = _ember
	if skill == "haste":
		self.texture = _haste
	if skill == "brent":
		self.texture = _brent
	if skill == "cliff":
		self.texture = _cliff
	if skill == "turn_undead":
		self.texture = _turn_undead
	if skill == "opal":
		self.texture = _opal
	if skill == "gold":
		self.texture = _gold
