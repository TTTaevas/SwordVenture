extends Node2D

var game_clock = 0

func _ready():
	$Enemy_screen.connect("gold_change", func(i): PlayerVariables.gold += i)
	$Bottom_screen.connect("gold_change", func(i): PlayerVariables.gold -= i)

func _process(delta):
	game_clock += delta
	if int(game_clock) != 0:
		game_clock = 0
		
		var dps := 0.0
		var items = $Bottom_screen.bought_items
		
		var swords = items.filter(func(item): return item.category == "swords" and item.equipped == false)
		for i in swords:
			dps += i.dps
		
		var aps := dps
		if aps > 100:
			var divider = 10
			while aps / divider != int(aps / divider) or int(aps / divider) > 100:
				divider += 1
			aps /= divider
		
		PlayerVariables.damage_per_second = dps
		PlayerVariables.attacks_per_second = aps
		for i in aps:
			damage_with_sword((1.0 / aps) * (i + 1.0), dps / aps)

func damage_with_sword(timeout: float, damage: float):
	await get_tree().create_timer(timeout).timeout
	var enemies = $Enemy_screen.find_children("", "Area2D", false, false)
	enemies = enemies.filter(func(i): return i.health > 0)
	if damage != null and enemies.size() > 0:
		(enemies[0] if randi() % 31 < 30 else enemies.pick_random()).health -= damage
