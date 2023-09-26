extends Node2D

var paused := false
var button_scene := preload("res://scenes/menu_button.tscn")

const things_to_save_and_load = [
	"game_difficulty", "misc_effects", "level", "experience", "max_experience", "xp_effects",
	"gold", "gold_effects",
	"zone", "enemies_to_progress", "enemies_killed", "default_hp",
	"max_equipped_swords", "swords"
]
const items_properties_to_save_and_load = [
	"i_name", "price", "current_dps", "dps", "level", "equipped", "duration_left"
]

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	$Gray.position = Vector2(0, 0)
	
	var save_btn = button_scene.instantiate()
	save_btn.action = "Save"
	save_btn.description = "Save your progress!"
	save_btn.callable = save_game
	$Menu/Container.add_child(save_btn)
	
	var load_btn = button_scene.instantiate()
	load_btn.action = "Load"
	load_btn.description = "Load your progress!"
	load_btn.callable = load_game
	$Menu/Container.add_child(load_btn)

func _process(_delta):
	var screen := get_viewport_rect().size
	
	$Gray.size = screen
	$Border.position = screen / 4
	$Background.position = Vector2($Border.position.x + 20, $Border.position.y + 20)
	$Border.size = (screen / $Border.scale) / 2
	$Background.size = Vector2(((screen.x / $Background.scale.x) / 2) - 35, ((screen.y / $Background.scale.y) / 2) - 35)
	
	$Menu.position = $Background.position
	$Menu.size = $Background.size

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if paused == false:
			show()
		else:
			hide()
		paused = !paused
		get_tree().paused = paused

func save_game():
	var save_file = FileAccess.open("user://save.save", FileAccess.WRITE)
	
	var obj = {}
	for thing in things_to_save_and_load:
		obj[thing] = PlayerVariables[thing]
	save_file.store_line(JSON.stringify(obj))
	
	var items = []
	for item in get_tree().root.find_children("Item_*", "", true, false):
		var item_obj = {}
		for prprty in items_properties_to_save_and_load:
			item_obj[prprty] = item[prprty]
		items.push_back(item_obj)
	save_file.store_line(JSON.stringify(items))
	
	print("(SAVE_GAME FUNCTION) Game has been saved!")
	return "Game saved!"

func load_game():
	if not FileAccess.file_exists("user://save.save"):
		print("(LOAD_GAME FUNCTION) Unable to find a save file to load")
		return "No save file to load!"
	
	var save_file = FileAccess.open("user://save.save", FileAccess.READ)
	var data = JSON.parse_string(save_file.get_line())
	if not data:
		print("(LOAD_GAME FUNCTION) Failed to load a save file")
		return "Failed to load..."
	
	for thing in things_to_save_and_load:
		PlayerVariables[thing] = data[thing]
	
	var game = get_tree().root.find_child("Game", false, false)
	if is_instance_valid(game):
		game.find_child("Enemy_screen", true, false).free()
		var new_enemy_scene = load("res://scenes/enemy_screen.tscn")
		game.add_child(new_enemy_scene.instantiate())
		game.move_child(game.find_child("Enemy_screen", true, false), 0)
		
		var items = JSON.parse_string(save_file.get_line())
		for item in game.find_children("Item_*", "", true, false):
			for prprty in items_properties_to_save_and_load:
				var item_data = items.filter(func(i): return i.i_name == item.i_name)
				if len(item_data):
					item_data = item_data[0]
					item[prprty] = item_data[prprty]
	
	return "Ok!"
