extends Node2D

signal gold_change

var enemy = preload("res://enemy.tscn")
var max_health = 10
var zone = 1
var enemies_to_progress = 5
var enemies_killed = 0

var level = 1
var experience = 0
var max_exp = 10

var animation_ongoing := false

func _ready():
	$Zone.text = "Zone %s" % zone
	update_enemies_left(enemies_to_progress, enemies_killed)
	spawn_monster()
	
	var p = $Background.get_child(0).position.y - 90
	p += $Background.get_child(0).texture.get_height() * $Background.get_child(0).scale.y
	$Zone.position.y = p
	$Enemies_left.position.y = p

func _process(_delta):
	$Zone.size = $Zone.get_theme_font("font").get_string_size($Zone.text)
	$Enemies_left.size = $Enemies_left.get_theme_font("font").get_string_size($Enemies_left.text)
	$Zone.position.x = (get_viewport_rect().size.x / 2) - (($Zone.size.x + $Enemies_left.size.x + 40) / 2)
	$Enemies_left.position.x = $Zone.position.x + $Zone.size.x + 40
	
	if experience >= max_exp:
		experience = 0
		max_exp = round(max_exp * 1.4)
		level += 1

func death(e):
	enemies_killed += 1
	gold_change.emit(max(1, round(e.max_health / 10)))
	experience += zone
	update_enemies_left(enemies_to_progress, enemies_killed)
	var enemies := find_children("", "Area2D", false, false)
	
	if enemies.size() <= 0 or enemies.all(func(node): return node.health <= 0):
		await get_tree().create_timer(0.2).timeout

		if enemies_killed >= enemies_to_progress:
			# await get_tree().create_timer(0.5).timeout
			animation_ongoing = true
			await find_child("Background").animate(enemies)
			animation_ongoing = false
			zone += 1
			$Zone.text = "Zone %s" % zone
			update_enemies_left(10, 0)
		else:
			for i in enemies:
				i.free()
		
		spawn_monster()

func update_enemies_left(to_progress: int, killed: int):
	enemies_to_progress = to_progress
	enemies_killed = killed
	var enemies_left = to_progress - killed
	$Enemies_left.text = "%s enem%s left!" % [enemies_left, "ies" if enemies_left > 1 else "y"]

func spawn_monster():
	var monster := enemy.instantiate()
	monster.connect("enemy_death", death)
	var i = round((randf_range(max_health / 1.2, max_health * 1.2)) * zone)
	monster.max_health = i
	monster.health = i
	add_child(monster)

	var max_enemies = floor(get_viewport_rect().size.x / 200)
	if randi() % 5 == 4 and find_children("", "Area2D", false, false).size() < min(max_enemies, enemies_to_progress - enemies_killed):
		spawn_monster()
