extends Control

var category: String

func _process(_delta):
	$Container/VContainer/Stats.text = "Damage per second: %s
	Damage per attack: %s
	Attacks per second: %s" % [
		PlayerVariables.damage_per_second,
		PlayerVariables.damage_per_attack,
		PlayerVariables.attacks_per_second
	]
