extends Node2D

func _process(_delta):
	var screen := get_viewport_rect().size
	var elements := find_children("", "TextureRect")
	
	var size = 640
	while size < screen.x * 3:
		size += 640
	
	for i in elements:
		i.size.x = size
		
		if abs(i.position.x) > 640 :
			i.position.x = 0

func animate(max_time: float, normal_speed: float, enemies):
	var elements := find_children("", "TextureRect")
	var time := randf_range(0.90, max_time)
	var speed := normal_speed + (time / 2)
	
	var c = randi() % 3
	var positive := bool(randi() % 2)
	
	while time > 0:
		await get_tree().create_timer(0.01).timeout
		
		for i in len(elements):
			var e = elements[i]
			@warning_ignore("integer_division")
			e.position.x -= speed / ((i / 2) + 1)
		
		for i in enemies:
			i.position.x -= speed
		
		if time > 0.8:
			speed += 0.3
		elif enemies.any(func(i): return i.position.x > -100):
			time += 0.1
			speed += 0.2
		else:
			speed /= 1.05
		time -= 0.01
		
		var colors = [$Light.color.r, $Light.color.g, $Light.color.b, $Light.color.a]
		if positive:
			colors[c] += randf_range(0.00, 0.0005)
		else:
			colors[c] -= randf_range(0.00, 0.0005)
		if colors[c] > 0.7 and positive:
			positive = false
		if colors[c] < -0.2 and not positive:
			positive = true
		$Light.set_color(Color(colors[0], colors[1], colors[2], colors[3]))
	
	for i in enemies:
		i.free()
	
	return true
