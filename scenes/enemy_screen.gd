extends Node2D

signal player_target
var enemy_scene := preload("res://scenes/top/enemy.tscn")
var enemies_left := 0

var animation_ongoing := false

func _ready():
	spawn_enemy()
	var p = $Background.get_child(0).position.y - 90
	p += $Background.get_child(0).texture.get_height() * $Background.get_child(0).scale.y
	$Zone.position.y = p
	$Enemies_left.position.y = p

func _process(_delta):
	enemies_left = PlayerVariables.enemies_to_progress - PlayerVariables.enemies_killed
	$Enemies_left.text = "%s enem%s left!" % [PlayerVariables.displayNumber(enemies_left), "ies" if enemies_left > 1 else "y"]
	$Zone.text = "Zone %s" % PlayerVariables.displayNumber(PlayerVariables.zone)
	
	$Zone.size = $Zone.get_theme_font("font").get_string_size($Zone.text)
	$Enemies_left.size = $Enemies_left.get_theme_font("font").get_string_size($Enemies_left.text)
	$Zone.position.x = (get_viewport_rect().size.x / 2) - (($Zone.size.x + $Enemies_left.size.x + 40) / 2)
	$Enemies_left.position.x = $Zone.position.x + $Zone.size.x + 40

func pacification(method, e):
	if method == "death":
		PlayerVariables.enemies_killed += 1
		PlayerVariables.gain_gold(max(1, int(e.max_health / 10)))
		PlayerVariables.gain_experience(PlayerVariables.zone)
	elif method == "flee":
		var enemy = e.duplicate()
		for property in e.get_property_list():
			if property.usage == PROPERTY_USAGE_SCRIPT_VARIABLE: 
				enemy[property.name] = e[property.name]
		PlayerVariables.enemies_fled.push_back(enemy)
		
	var enemies := find_children("enemy_*", "", false, false)
	if enemies.size() <= 0 or enemies.all(func(enemy): return (enemy.health <= 0 or enemy.fleeing)):
		await get_tree().create_timer(0.2).timeout

		if PlayerVariables.enemies_killed >= PlayerVariables.enemies_to_progress:
			animation_ongoing = true
			await find_child("Background").animate(4.00, 0.75, enemies)
			animation_ongoing = false
			
			PlayerVariables.zone += 1
			PlayerVariables.enemies_killed = 0
			PlayerVariables.enemies_to_progress = 10 if randi() % 101 < 100 else 25
		else:
			for i in enemies:
				if is_instance_valid(i):
					i.free()
		
		spawn_enemy()

func spawn_enemy():
	var enemies := find_children("enemy_*", "", false, false)
	if PlayerVariables.enemies_fled.size() >= 1 and PlayerVariables.enemies_fled.size() + enemies.size() >= enemies_left:
		animation_ongoing = true
		await find_child("Background").animate(1.0, 50.0, enemies)
		animation_ongoing = false
		
		var enemy = PlayerVariables.enemies_fled.front()
		enemy.fleeing = false
		enemy.panic = 0
		enemy.shake = 0
		enemy.connect("pacification", pacification)
		enemy.connect("player_target", relay)
		add_child(enemy)
		PlayerVariables.enemies_fled.remove_at(0)
	else:
		var enemy := enemy_scene.instantiate()
		enemy.connect("pacification", pacification)
		enemy.connect("player_target", relay)
		enemy.name = "enemy_%s" % enemy.get_instance_id()
		add_child(enemy)
	
	var max_enemies = floor(get_viewport_rect().size.x / 200)
	enemies = find_children("enemy_*", "", false, false)
	if randi() % 5 == 4 and enemies.size() < min(max_enemies, enemies_left):
		spawn_enemy()

func relay(target: Area2D):
	player_target.emit(target)
