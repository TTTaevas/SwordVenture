extends Node2D

var gold = 0
var game_clock = 0

func _ready():
	$Enemy_screen.connect("gold_change", func(i): gold += i)
	$Bottom_screen.connect("gold_change", func(i): gold -= i)

func _process(delta):
	game_clock += delta
	if int(game_clock) != 0:
		game_clock = 0
		
		var dps = 0
		var items = $Bottom_screen.bought_items
		
		var swords = items.filter(func(item): return item.category == "swords" and item.equipped == false)
		for i in swords:
			dps += i.dps
		
		var attacks_per_second := 10 if dps >= 10 else 5 if dps >= 5 else 1
		for i in attacks_per_second:
			damage_with_sword((1.0 / attacks_per_second) * (i + 1.0), dps / attacks_per_second)

func damage_with_sword(timeout: float, damage: float):
	await get_tree().create_timer(timeout).timeout
	var enemies = $Enemy_screen.find_children("", "Area2D", false, false)
	enemies = enemies.filter(func(i): return i.health > 0)
	if damage != null and enemies.size() > 0:
		enemies[0].health -= damage
