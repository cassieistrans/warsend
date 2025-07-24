extends Node2D

var dagger_dmg = 3
var bss_dmg = 4
var ss_dmg = 6
var battleaxe_dmg = 9
var serrated_dmg = 10
var claymore_dmg = 11
var cliff_modifier

func _ready():
	# Disable all hitboxes on load
	$dagger_hb/CollisionShape2D.disabled = true
	$ss_hb/CollisionShape2D.disabled = true
	$battleaxe_hb/CollisionShape2D.disabled = true
	$bss_hb/CollisionShape2D.disabled = true
	$claymore_hb/CollisionShape2D.disabled = true
	$serrated_hb/CollisionShape2D.disabled = true

	# Disable all sprites on load
	$straight_sword.visible = false
	$ss_smear.visible = false
	$dagger.visible = false
	$dagger_smear.visible = false
	$broken_straight_sword.visible = false
	$bss_smear.visible = false
	$battle_axe.visible = false
	$battleaxe_smear.visible = false
	$claymore.visible = false
	$claymore_smear.visible = false
	$serrated_sword.visible = false
	$serrated_smear.visible = false


func setWeapon(weapon):
	# Disable all sprite visibility
	$straight_sword.visible = false
	$dagger.visible = false
	$broken_straight_sword.visible = false
	$battle_axe.visible = false
	$claymore.visible = false
	$serrated_sword.visible = false
	
	# Set new weapon's visibility
	if weapon == "dagger":
		$dagger.visible = true
	if weapon == "bss":
		$broken_straight_sword.visible = true
	if weapon == "ss":
		$straight_sword.visible = true
	if weapon == "battle_axe":
		$battle_axe.visible = true
	if weapon == "claymore":
		$claymore.visible = true
	if weapon == "serrated":
		$serrated_sword.visible = true

func death():
	$straight_sword.visible = false
	$ss_smear.visible = false
	$dagger.visible = false
	$dagger_smear.visible = false
	$broken_straight_sword.visible = false
	$bss_smear.visible = false
	$battle_axe.visible = false
	$battleaxe_smear.visible = false
	$claymore.visible = false
	$claymore_smear.visible = false
	$serrated_sword.visible = false
	$serrated_smear.visible = false

# Damage functions
func _on_dagger_hb_area_entered(area):
	if area.is_in_group("enemy"):
		area.get_parent().Hit(dagger_dmg)

func _on_ss_hb_area_entered(area):
	if area.is_in_group("enemy"):
		area.get_parent().Hit(ss_dmg)

func _on_battleaxe_hb_area_entered(area):
	if area.is_in_group("enemy"):
		area.get_parent().Hit(battleaxe_dmg)

func _on_bss_hb_area_entered(area):
	if area.is_in_group("enemy"):
		area.get_parent().Hit(bss_dmg)

func _on_claymore_hb_area_entered(area):
	if area.is_in_group("enemy"):
		area.get_parent().Hit(claymore_dmg)

func _on_serrated_hb_area_entered(area):
	if area.is_in_group("enemy"):
		area.get_parent().Hit(serrated_dmg)
