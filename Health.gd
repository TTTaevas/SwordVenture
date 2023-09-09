extends ProgressBar

func _init():
	show_percentage = false

func _process(_delta):
	var monster_position = get_parent().position
	var new_position := get_viewport_rect().size
	new_position.x = monster_position.x
	new_position.x -= size.x / 2
	new_position.y = monster_position.y
	new_position.y -= 100
	global_position = new_position
	
	if get_parent() != null:
		self.value = get_parent().get("health")
		self.max_value = get_parent().get("max_health")

func _on_enemy_health_change(health, max_health):
	self.value = health
	self.max_value = max_health
