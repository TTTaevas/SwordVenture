extends Node2D

var enemy = preload("res://enemy.tscn")
var zone = 1
var enemies_to_progress = 5
var enemies_killed = 0

var level = 1
var experience = 0
var max_exp = 10

var gold = 0

var animation_ongoing := false

func _ready():
	spawn_monster()

func _process(_delta):
	if experience >= max_exp:
		experience = 0
		max_exp = round(max_exp * 1.4)
		level += 1

func death(e):
	enemies_killed += 1
	gold += round(e.max_health / 10)
	experience += zone
	$Status.find_child("Enemies").text = "Enemies: 
		%s/%s" % [enemies_killed, enemies_to_progress]
	var enemies := find_children("", "Area2D", false, false)
	
	if enemies.size() < 0 or enemies.all(func(node): return node.health <= 0):
		await get_tree().create_timer(0.2).timeout

		if enemies_killed >= enemies_to_progress:
			# await get_tree().create_timer(0.5).timeout
			animation_ongoing = true
			await find_child("Background").animate(enemies)
			animation_ongoing = false
			zone += 1
			$Status.find_child("Zone").text = "Zone: {zone}".format({"zone": zone})
			enemies_to_progress = 10
			enemies_killed = 0
			$Status.find_child("Enemies").text = "Enemies: 
				%s/%s" % [enemies_killed, enemies_to_progress]
		else:
			for i in enemies:
				i.free()
		
		spawn_monster()
		

func spawn_monster():
	var monster := enemy.instantiate()
	monster.connect("enemy_death", death)
	add_child(monster)

	var max_enemies = floor(get_viewport_rect().size.x / 200)
	if randi() % 5 == 4 and find_children("", "Area2D", false, false).size() < min(max_enemies, enemies_to_progress - enemies_killed):
		spawn_monster()
