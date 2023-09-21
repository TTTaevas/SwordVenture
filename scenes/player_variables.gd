extends Node

var misc_effects = []

var level := 1
var experience := 0
var max_experience := 50
var xp_effects := []
func gain_experience(xp):
	for effect in xp_effects:
		xp *= effect
	
	while xp > 0:
		experience += 1
		if experience >= max_experience:
			level += 1
			experience = 0
			max_experience = round(PlayerVariables.max_experience * 1.4)
		xp -= 1

var gold := 0
var gold_effects := []
func gain_gold(g):
	for effect in gold_effects:
		g *= effect
	
	while g > 0:
		gold += 1
		g -= 1

var zone := 1
var enemies_to_progress := 5
var enemies_killed := 0
var enemies_fled := []
var default_hp := 10

var damage_per_second := 0
var damage_per_attack := 0
var attacks_per_second := 0
var swords = []
