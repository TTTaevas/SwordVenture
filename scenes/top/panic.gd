extends TextureProgressBar

func _process(_delta):
	var monster := get_parent()
	var new_position = monster.position
	new_position.x -= (size.x * scale.x) / 2
	new_position.y -= 120
	global_position = new_position
	
	self.value = monster.panic
	self.max_value = 10
