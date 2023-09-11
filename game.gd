extends Node2D

var gold = 0
var game_clock = 0
var second_last_damaged = -1

func _ready():
	$Enemy_screen.connect("gold_change", func(i): gold += i)
	$Shop.connect("gold_change", func(i): gold -= i)

func _process(delta):
	game_clock += delta
	if int(game_clock) != second_last_damaged:
		second_last_damaged = int(game_clock)
		
		var enemies = $Enemy_screen.find_children("", "Area2D", false, false)
		enemies = enemies.filter(func(i): return i.health > 0)
		
		var dps = 0
		var items = $Shop.bought_items
		for i in items:
			dps += i.dps
		
		if dps != null and enemies.size() > 0:
			enemies[0].health -= dps
