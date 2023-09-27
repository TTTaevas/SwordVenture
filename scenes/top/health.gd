extends TextureProgressBar

func _process(_delta):
	var monster := get_parent()
	var new_position = monster.position
	new_position.x -= size.x / 2
	new_position.y -= 100
	global_position = new_position
	
	self.value = ceil(monster.health)
	self.max_value = monster.max_health
	
	$Label.text = "%s / %s HP" % [
		PlayerVariables.displayNumber(max(0, monster.health)),
		PlayerVariables.displayNumber(monster.max_health)
	]
	$Label.size = $Label.get_theme_font("font").get_string_size($Label.text)
	$Label.position.x = (size.x / 2) - ($Label.size.x / 2) + 2
