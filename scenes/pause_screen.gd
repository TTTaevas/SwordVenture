extends Node2D

var paused := false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	$Gray.position = Vector2(0, 0)

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
