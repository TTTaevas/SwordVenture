extends TextureProgressBar

func _process(_delta):
	var monster = get_parent()
	var collision_position = monster.find_child("Collision", false, false).position
	var new_position := get_viewport_rect().size
	new_position.x = monster.position.x
	new_position.x -= size.x / 2
	new_position.y = monster.position.y
	new_position.y -= 100
	global_position = new_position
	
	self.value = monster.health
	self.max_value = monster.max_health
	$Label.text = "%s / %s HP" % [max(0, monster.health), monster.max_health]
	$Label.size = $Label.get_theme_font("font").get_string_size($Label.text)
	$Label.position.x = (size.x / 2) - ($Label.size.x / 2) + 2
