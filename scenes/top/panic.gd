extends TextureProgressBar

func _process(_delta):
	var monster = get_parent()
	var new_position := get_viewport_rect().size
	new_position.x = monster.position.x
	new_position.x -= (size.x * scale.x) / 2
	new_position.y = monster.position.y
	new_position.y -= 120
	global_position = new_position
	
	self.value = monster.panic
	self.max_value = 10
