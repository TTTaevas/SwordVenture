extends TextureProgressBar

func _process(_delta):
	var enemy := get_parent()
	if not is_instance_valid(enemy) or enemy.get("panic") == null:
		return
	
	position = Vector2(((-size.x * scale.x) / 2) + 1, -120)
	
	self.value = enemy.panic
	self.max_value = 10
