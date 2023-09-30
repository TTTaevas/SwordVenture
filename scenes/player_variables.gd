extends Node

# Lower is easier
var game_difficulty := 1.00
var ascends := 0
var ascending := false

var misc_effects = []
var tap_effects = []

var level := 1
var experience := 0.0
var max_experience := 50.0 * game_difficulty
var xp_effects := []
func gain_experience(xp):
	for effect in xp_effects:
		xp *= effect
	
	experience += xp / game_difficulty
	if experience >= max_experience:
		level += 1
		experience -= max_experience
		max_experience = round(max_experience * 1.4)
		var sound = get_parent().find_child("SoundLevelUp", true, false)
		if is_instance_valid(sound):
			sound.play()

var gold := 0.0
var gold_effects := []
func gain_gold(g):
	for effect in gold_effects:
		g *= effect
	while g > 0:
		gold += 1 / game_difficulty
		g -= 1

var zone := 1.0
var enemies_to_progress := 5
var enemies_killed := 0
var enemies_fled := []
var default_hp := 10.0 * game_difficulty

var max_equipped_swords := 1
var swords = []
var damage_per_second := 0.0
var damage_per_attack := 0.0
var attacks_per_second := 100

func displayNumber(num):
	var x := str(ceil(num))
	var y := 0
	if len(x) < 4:
		return x
	
	while len(x) > 6:
		y += 1
		x = x.substr(0, len(x) - 3)
	
	var z := len(x) - 3
	return "%s,%s%s" % [x.substr(0, z), x.substr(z, len(x)),
	["","K","M","B","T","q","Q","s","S","O","N","d","U","D","!","@","#","$","%","^","&","*"][y]]

func ascend():
	ascending = true
	ascends += 1
	game_difficulty = game_difficulty - 0.05 if game_difficulty - 0.05 > 0.0 else game_difficulty / 2
	
	get_tree().paused = true
	var game = get_tree().root.find_child("Game", false, false)
	game.find_child("Ascend_sound", true, false).play()
	for i in 16:
		await get_tree().create_timer(0.03).timeout
		game.find_child("Ascend_light", true, false).energy = i
	
	max_equipped_swords = 1
	swords = []
	zone = 1.0
	enemies_to_progress = 5
	enemies_killed = 0
	enemies_fled = []
	default_hp = 10.0 * game_difficulty
	gold = 0.0
	gold_effects = []
	level = 1
	experience = 0.0
	max_experience = 50.0 * game_difficulty
	xp_effects = []
	misc_effects = []
	tap_effects = []
		
	game.find_child("Enemy_screen", true, false).free()
	game.find_child("Bottom_screen", true, false).free()
	
	var new_enemy_scene = load("res://scenes/enemy_screen.tscn")
	game.add_child(new_enemy_scene.instantiate())
	game.move_child(game.find_child("Enemy_screen", true, false), 0)
	
	var new_bottom_scene = load("res://scenes/bottom_screen.tscn")
	game.add_child(new_bottom_scene.instantiate())
	game.move_child(game.find_child("Bottom_screen", true, false), 1)
	
	get_tree().paused = false
	ascending = false
	
	for i in 16:
		await get_tree().create_timer(0.10).timeout
		game.find_child("Ascend_light", true, false).energy = 15 - i
