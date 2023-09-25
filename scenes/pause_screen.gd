extends Node2D

var paused := false
var button_scene := preload("res://scenes/menu_button.tscn")

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	$Gray.position = Vector2(0, 0)
	
	var save = button_scene.instantiate()
	save.action = "Save"
	save.description = "Save your progress!"
	save.callable = save_game
	$Menu/Container.add_child(save)

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
	var save_nodes = get_tree().get_nodes_in_group("ToSave")
	for node in save_nodes:
		if node.scene_file_path.is_empty():
			print("(SAVE_GAME FUNCTION) Node is not an instanced scene, skipping: ", node.name)
			continue
		if not node.has_method("save"):
			print("(SAVE_GAME FUNCTION) Node is missing a save() func, skipping: ", node.name)
			continue
		
		var data = node.call("save")
		var json_string = JSON.stringify(data)
		save_file.store_line(json_string)
		
	print("(SAVE_GAME FUNCTION) Game has been saved!")
	return "Game saved!"

func load_game():
	if not FileAccess.file_exists("user://save.save"):
		print("(LOAD_GAME FUNCTION) Unable to find a save file to load")
		return
	
	var save_nodes = get_tree().get_nodes_in_group("ToSave")
	for node in save_nodes:
		node.queue_free()
