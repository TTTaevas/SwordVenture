extends Control

var category: String

func _process(_delta):
	if category == "swords":
		$Container/VContainer/Stats.text = "Damage per second: %s
		Damage per attack: %s
		Attacks per second: %s" % [
			PlayerVariables.damage_per_second,
			PlayerVariables.damage_per_attack,
			PlayerVariables.attacks_per_second
		]
	elif category == "potions":
		$Container/VContainer/Stats.text = "Active potions: %s
		
		" % [
			len(find_children("Item*", "", true, false).filter(func(p): return p.level > 0)),
		]
