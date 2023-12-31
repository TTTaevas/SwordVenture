extends Node2D

var paused := false
var button_scene := preload("res://scenes/menu_button.tscn")

const things_to_save_and_load = [
	"game_difficulty", "ascends", "misc_effects", "level", "experience", "max_experience", "xp_effects",
	"gold", "gold_effects",
	"zone", "enemies_to_progress", "enemies_killed", "default_hp",
	"max_equipped_swords", "swords"
]
const items_properties_to_save_and_load = [
	"i_name", "price", "current_dps", "dps", "level", "level_multi", "equipped", "duration_left"
]

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	$Gray.position = Vector2(0, 0)
	
	var continue_btn = button_scene.instantiate()
	continue_btn.action = "Continue"
	continue_btn.description = "Continue your adventure!"
	continue_btn.callable = continue_game
	$Menu/Container.add_child(continue_btn)
	
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
	
	var screen_btn = button_scene.instantiate()
	screen_btn.action = "Toggle Fullscreen"
	screen_btn.description = "Decide the way you quest!"
	screen_btn.callable = screen_game
	$Menu/Container.add_child(screen_btn)
	
	var quit_btn = button_scene.instantiate()
	quit_btn.action = "Quit"
	quit_btn.description = "Take a well deserved break!"
	quit_btn.callable = quit_game
	quit_btn.texture_normal = load("res://sprites/shop/button-red.png")
	quit_btn.texture_pressed = load("res://sprites/shop/button-red-pressed.png")
	$Menu/Container.add_child(quit_btn)

func _process(_delta):
	var screen := get_viewport_rect().size
	
	$Gray.size = screen
	if screen.x < 1080 or screen.y < 720:
		$Border.position = screen / 12
		$Border.size = (screen / $Border.scale) - ($Border.position * 4)
	else:
		$Border.size = Vector2(720 / $Border.scale.x, 480 / $Border.scale.y)
		$Border.position = (screen / 2) - (($Border.size * $Border.scale) / 2)
	$Background.position = Vector2($Border.position.x + 20, $Border.position.y + 20)
	$Background.size = ($Border.size * $Border.scale) - Vector2(35, 35)
	
	var s = min(max(0.70, min($Border.size.x / 1080, $Border.size.y / 920)), 1.00)
	$Menu.position = $Background.position
	$Menu.scale = Vector2(s, s)
	$Menu.size = $Background.size / s
	
	if PlayerVariables.enemies_killed >= PlayerVariables.enemies_to_progress:
		$Menu/Container.find_child("SaveButton", false, false).disabled = true
	else:
		$Menu/Container.find_child("SaveButton", false, false).disabled = false

func _input(event):
	if PlayerVariables.ascending:
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if paused == false:
			show()
		else:
			hide()
		paused = !paused
		get_tree().paused = paused

func continue_game():
	paused = false
	get_tree().paused = false
	hide()
	return "Good luck!"

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
	return "Adventure saved!"

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
		if data.get(thing) != null:
			PlayerVariables[thing] = data[thing]
		else:
			print("(LOAD_GAME FUNCTION) Variable `%s` didn't exist in save file" % thing)
	
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
					if item_data.get(prprty) != null:
						item[prprty] = item_data[prprty]
					else:
						print("(LOAD_GAME FUNCTION) Property `%s` in %s didn't exist in save file" % [
							prprty, item_data.i_name
						])
	
	PlayerVariables.enemies_fled = []
	return "Welcome back!"

func screen_game():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		return "No longer in fullscreen!"
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		return "Now in fullscreen!"

func quit_game():
	get_tree().quit()
	return "See you!!"
