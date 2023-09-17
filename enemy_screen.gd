extends Node2D

signal gold_change

var enemy_scene = preload("res://enemy.tscn")
var enemies_left = 0

var animation_ongoing := false

func _ready():
	spawn_enemy()
	var p = $Background.get_child(0).position.y - 90
	p += $Background.get_child(0).texture.get_height() * $Background.get_child(0).scale.y
	$Zone.position.y = p
	$Enemies_left.position.y = p

func _process(_delta):
	enemies_left = PlayerVariables.enemies_to_progress - PlayerVariables.enemies_killed
	$Enemies_left.text = "%s enem%s left!" % [enemies_left, "ies" if enemies_left > 1 else "y"]
	$Zone.text = "Zone %s" % PlayerVariables.zone
	
	$Zone.size = $Zone.get_theme_font("font").get_string_size($Zone.text)
	$Enemies_left.size = $Enemies_left.get_theme_font("font").get_string_size($Enemies_left.text)
	$Zone.position.x = (get_viewport_rect().size.x / 2) - (($Zone.size.x + $Enemies_left.size.x + 40) / 2)
	$Enemies_left.position.x = $Zone.position.x + $Zone.size.x + 40
	
	if PlayerVariables.experience >= PlayerVariables.max_experience:
		PlayerVariables.experience = 0
		PlayerVariables.max_experience = round(PlayerVariables.max_experience * 1.4)
		PlayerVariables.level += 1

func pacification(method, e):
	if method == "death":
		PlayerVariables.enemies_killed += 1
		gold_change.emit(max(1, round(e.max_health / 10)))
		PlayerVariables.experience += PlayerVariables.zone
	elif method == "flee":
		PlayerVariables.enemies_to_progress -= 1
		
	var enemies := find_children("enemy_*", "", false, false)
	if enemies.size() <= 0 or enemies.all(func(enemy): return (enemy.health <= 0 or enemy.fleeing)):
		await get_tree().create_timer(0.2).timeout

		if PlayerVariables.enemies_killed >= PlayerVariables.enemies_to_progress:
			animation_ongoing = true
			await find_child("Background").animate(enemies)
			animation_ongoing = false
			
			PlayerVariables.zone += 1
			PlayerVariables.enemies_killed = 0
			PlayerVariables.enemies_to_progress = 10
		else:
			for i in enemies:
				i.free()
		
		spawn_enemy()

func spawn_enemy():
	var enemy := enemy_scene.instantiate()
	enemy.connect("pacification", pacification)
	enemy.name = "enemy_%s" % find_children("enemy_*", "", false, false).size()
	add_child(enemy)

	var max_enemies = floor(get_viewport_rect().size.x / 200)
	if randi() % 5 == 4 and find_children("enemy_*", "", false, false).size() <min(max_enemies, enemies_left):
		spawn_enemy()
