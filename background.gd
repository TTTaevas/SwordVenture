extends Node2D

func _process(_delta):
	var screen := get_viewport_rect().size
	var elements := get_children()
	
	var size = 640
	while size < screen.x * 3:
		size += 640
	
	for i in elements:
		i.size.x = size
		
		if abs(i.position.x) > 640 :
			i.position.x = 0

func animate(enemies):
	var elements := get_children()
	var time := randf_range(0.90, 3.50)
	var speed := 2.0 + (time / 2)
	
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
	
	for i in enemies:
		i.free()
	
	return true
