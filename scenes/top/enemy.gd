extends Area2D

signal pacification

var enemy_sprite := {
	normal = "",
	hurt = "",
	dead = "",
	offset = 0,
	collision = createShape(0, 0, 0)
}
var mouse_on_sprite := false

var healthbar = preload("res://scenes/top/health.tscn")
var panicbar = preload("res://scenes/top/panic.tscn")
var found_dead := false
var latest_click := Time.get_unix_time_from_system()

var panic := 0
var shake := 0
var fleeing := false
var fled_once := false
var healing := false

var max_health: float
var health: float

var personality: String

func _on_enemy_mouse_entered():
	mouse_on_sprite = true
func _on_enemy_mouse_exited():
	mouse_on_sprite = false

func createShape(x: int, y: int, offset: int):
	var blob_shape = RectangleShape2D.new()
	blob_shape.size = Vector2(x, y)
	var blob_collision = CollisionShape2D.new()
	blob_collision.name = "Collision"
	blob_collision.set_shape(blob_shape)
	blob_collision.position.y += offset
	return blob_collision

func _ready():
	if max_health > 0:
		return
	var enemies = [
		{normal = load("res://sprites/enemies/blob.png"), hurt = load("res://sprites/enemies/blobHurt.png"), dead = load("res://sprites/enemies/blobDead.png"),
		offset = 0, collision = createShape(82, 70, 0)},
		{normal = load("res://sprites/enemies/ghost.png"), hurt = load("res://sprites/enemies/ghostHurt.png"), dead = load("res://sprites/enemies/ghostDead.png"),
		offset = -20, collision = createShape(76, 96, -2)},
		{normal = load("res://sprites/enemies/skeleton.png"), hurt = load("res://sprites/enemies/skeletonHurt.png"), dead = load("res://sprites/enemies/skeletonHurt.png"),
		offset = -10, collision = createShape(42, 77, 10)},
	]
	enemy_sprite = enemies.pick_random()
	
	var personalities := ["plain", "coward", "persistent", "caring"]
	personality = personalities.pick_random()
	
	var default_hp = randf_range(PlayerVariables.default_hp * 0.8, PlayerVariables.default_hp * 1.2)
	health = default_hp * (((PlayerVariables.zone - 1) * 1.88) if PlayerVariables.zone > 1 else 1.0)
	health *= max(1, float((int(PlayerVariables.zone) - 1) % 10) / 5)
	if personality == "persistent":
		health *= 1.3
	elif personality == "caring":
		health *= 0.7
	health = round(health)
	max_health = health
	
	var health_bar = healthbar.instantiate()
	add_child(health_bar)
	
	if personality == "coward":
		var panic_bar = panicbar.instantiate()
		add_child(panic_bar)
	
	var sprite := Sprite2D.new()
	sprite.name = "Sprite"
	sprite.texture = enemy_sprite.normal
	add_child(sprite)
	add_child(enemy_sprite.collision)
	global_position = Vector2(-500, 214 + enemy_sprite.offset)

func _process(_delta):
	if fleeing or "animation_ongoing" in get_parent() and get_parent().animation_ongoing == true:
		return
	
	var new_position := get_viewport_rect().size
	new_position.x /= 2
	
	var enemies := get_parent().find_children("enemy_*", "", false, false)
	var i := enemies.find(self)
	var p := enemies.size() - 1
	if p & 1 == 1:
		new_position.x -= 100
	
	@warning_ignore("integer_division")
	while i < p / 2:
		new_position.x -= 200
		i += 1
	@warning_ignore("integer_division")
	while i > p / 2:
		new_position.x += 200
		i -= 1
	
	if personality == "coward":
		new_position.x += shake
	global_position.x = new_position.x
	
	if personality == "caring" and not fleeing and not found_dead and not healing:
		var alive = enemies.filter(func(e): return !e.fleeing and !e.found_dead)
		var injured = alive.filter(func(e): return e.health < e.max_health)
		for e in injured:
			var dice_1 = floor(randf_range(1, ((100 * (e.health - float((int(PlayerVariables.zone) - 1) % 10) / 5)) / e.max_health)))
			var dice_2 = randf_range(50, 100) if e.name == name and alive.size() == 1 else floor(randf_range((100 * (health + float((int(PlayerVariables.zone) - 1) % 10) / 5)) / max_health, 120))
			if dice_1 == 1 and dice_2 > 90:
				heal(e, int(e.max_health / (20 if e.personality == "caring" else 10)))
	
	if health <= 0 and not found_dead:
		found_dead = true
		$Sprite.texture = enemy_sprite.get("dead")
		pacification.emit("death", self)
		
	elif personality == "coward" and not fleeing and not found_dead:
		@warning_ignore("integer_division")
		var dice = floor(randf_range(1, ((100 * (health + int(PlayerVariables.level / 2))) / max_health)))
		
		if dice <= (panic * 3) or fled_once:
			shake += 2 if dice <= (panic) else -shake + -2
		if dice == 1:
			panic += 1
		if panic == 10:
			$Sprite.texture = enemy_sprite.get("hurt")
			fleeing = true
			fled_once = true
			var speed := 1.3
			while position.x < get_viewport_rect().size.x + 200:
				await get_tree().create_timer(0.01).timeout
				position.x += speed
				speed += 0.7
			pacification.emit("flee", self)

func _input(ev):
	if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT:
		if ev.pressed and mouse_on_sprite and health > 0 and not fleeing:
			$SoundHit.play()
			health -= PlayerVariables.level
			if "Envy's Blood" in PlayerVariables.misc_effects:
				health -= floor(PlayerVariables.gold * 0.01)
			PlayerVariables.gain_experience(1)
			
			var click_time := Time.get_unix_time_from_system()
			latest_click = click_time
			$Sprite.texture = enemy_sprite.get("hurt")
			
			await get_tree().create_timer(0.2).timeout
			if click_time == latest_click and health > 0 and not fleeing and not fled_once:
				$Sprite.texture = enemy_sprite.get("normal")

func heal(enemy: Area2D, amount: int):
	healing = true
	var magic_particles := []
	var healing_particles := []
	
	for i in 3:
		var particle = TextureRect.new()
		particle.texture = preload("res://sprites/particle_blue.png")
		particle.position = Vector2(randf_range(-50, 50), randf_range(-25, 50))
		particle.name = "particle_blue_%s" % particle.get_instance_id()
		await get_tree().create_timer(0.05).timeout
		add_child(particle)
		magic_particles.push_back(particle)
	for i in 3:
		var particle = TextureRect.new()
		particle.texture = preload("res://sprites/particle_green.png")
		particle.position = Vector2(randf_range(-50, 50), randf_range(-50, 0))
		particle.name = "particle_green_%s" % particle.get_instance_id()
		await get_tree().create_timer(0.05).timeout
		enemy.add_child(particle)
		healing_particles.push_back(particle)
	
	for i in 50:
		for e in magic_particles:
			e.position.y -= 1
		for e in healing_particles:
			e.position.y += 1
		await get_tree().create_timer(0.01).timeout
	
	for e in magic_particles:
		e.free()
	for e in healing_particles:
		e.free()
	healing = false
	
	if not found_dead and not fleeing and not enemy.found_dead and not enemy.fleeing:
		if enemy.health < enemy.max_health:
			enemy.health += max(3, min(enemy.max_health - enemy.health, amount))
