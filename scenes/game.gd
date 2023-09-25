extends Node2D

var game_clock := 0.0
var sword_target: Area2D
var how_long_sword_target := 0.0

func _ready():
	$Pause_screen.position = Vector2(0, 0)
	$Pause_screen.hide()

func _process(delta):
	game_clock += delta
	if int(game_clock) != 0:
		game_clock = 0
		
		var dps := 0.0
		for sword in PlayerVariables.swords.filter(func(s): return s.equiped):
			dps += sword.dps
		
		var aps := dps
		if aps > 100:
			var divider = 10
			while aps / divider != int(aps / divider) or int(aps / divider) > 100:
				divider += 1
			aps /= divider
		
		PlayerVariables.damage_per_second = dps
		PlayerVariables.damage_per_attack = max(0, dps / aps)
		PlayerVariables.attacks_per_second = aps
		for i in aps:
			damage_with_sword((1.0 / aps) * (i + 1.0), dps / aps)

func damage_with_sword(timeout: float, damage: float):
	await get_tree().create_timer(timeout).timeout
	var enemies = $Enemy_screen.find_children("", "Area2D", false, false)
	enemies = enemies.filter(func(i): return i.health > 0 and i.fleeing == false)
	enemies.sort_custom(func(a,b): return (100 * a.health) / a.max_health < (100 * b.health) / b.max_health)
	
	if damage != null and enemies.size() > 0:
		if !is_instance_valid(sword_target) or sword_target.fleeing or sword_target.found_dead:
			sword_target = enemies[0]
			how_long_sword_target = 1
		elif how_long_sword_target > 15:
			var other_enemies = enemies.filter(func(a): return a.name != sword_target.name)
			sword_target = other_enemies.pick_random() if len(other_enemies) > 0 else sword_target
			how_long_sword_target = 1
		else:
			how_long_sword_target += 1 / PlayerVariables.attacks_per_second
		
		(sword_target if randi() % 3 < 30 else enemies.pick_random()).health -= damage

func _on_enemy_screen_player_target(target: Area2D):
	sword_target = target
	how_long_sword_target = 1
