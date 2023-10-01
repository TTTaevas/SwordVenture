extends TextureProgressBar

func _process(_delta):
	var enemy := get_parent()
	if not is_instance_valid(enemy) or enemy.get("health") == null:
		return
	
	$Label.text = "%s / %s HP" % [
		PlayerVariables.displayNumber(max(0, enemy.health)),
		PlayerVariables.displayNumber(enemy.max_health)
	]
	$Label.size = $Label.get_theme_font("font").get_string_size($Label.text)
	$Label.position.x = (size.x / 2) - ($Label.size.x / 2) + 2
	size.x = max(183, $Label.size.x + 20)
	position = Vector2(((-size.x * scale.x) / 2) + 1, -100)
	
	self.value = ceil(enemy.health)
	self.max_value = enemy.max_health
