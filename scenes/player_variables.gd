extends Node

# Lower is easier
var game_difficulty := 1.0

var misc_effects = []

var level := 1
var experience := 0.0
var max_experience := 50 * game_difficulty
var xp_effects := []
func gain_experience(xp):
	for effect in xp_effects:
		xp *= effect
	
	while xp > 0:
		experience += 1 / game_difficulty
		if experience >= max_experience:
			level += 1
			experience = 0
			max_experience = round(max_experience * 1.4)
			var sound = get_parent().find_child("SoundLevelUp", true, false)
			if is_instance_valid(sound):
				sound.play()
		xp -= 1

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
