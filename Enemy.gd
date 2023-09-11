extends Area2D

signal enemy_death

var enemy_sprite := {
	normal = "",
	hurt = "",
	dead = "",
	offset = 0,
	collision = createShape(0, 0, 0)
}
var mouse_on_sprite := false

var healthbar = preload("res://health.tscn")
var found_dead := false
var latest_click := Time.get_unix_time_from_system()

var max_health: int
var health: int

func createShape(x: int, y: int, offset: int):
	var blob_shape = RectangleShape2D.new()
	blob_shape.size = Vector2(x, y)
	var blob_collision = CollisionShape2D.new()
	blob_collision.set_shape(blob_shape)
	blob_collision.position.y += offset
	return blob_collision

func _init():
	var enemies = [
		{normal = load("res://sprites/blob.png"), hurt = load("res://sprites/hurtBlob.png"), dead = load("res://sprites/deadBlob.png"),
		offset = 0, collision = createShape(82, 70, 0)},
		{normal = load("res://sprites/ghost.png"), hurt = load("res://sprites/hurtGhost.png"), dead = load("res://sprites/deadGhost.png"),
		offset = -20, collision = createShape(76, 96, 0)},
		{normal = load("res://sprites/skeleton.png"), hurt = load("res://sprites/hurtSkeleton.png"), dead = load("res://sprites/hurtSkeleton.png"),
		offset = -10, collision = createShape(42, 77, 10)},
	]
	enemy_sprite = enemies.pick_random()
	
	var bar = healthbar.instantiate()
	add_child(bar)

func _ready():
	if health <= 0 or max_health <= 0:
		health = 10
		max_health = 10
	
	var sprite := Sprite2D.new()
	sprite.name = "Sprite"
	sprite.texture = enemy_sprite.normal
	add_child(sprite)
	add_child(enemy_sprite.collision)
	global_position = Vector2(-500, 214 + enemy_sprite.offset)

func _process(_delta):
	if "animation_ongoing" in get_parent() and get_parent().animation_ongoing == true:
		return
	
	var new_position := get_viewport_rect().size
	new_position.x /= 2
	
	var enemies := get_parent().find_children("", "Area2D", false, false)
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
			
	global_position.x = new_position.x
	
	if health <= 0 and not found_dead:
		found_dead = true
		$Sprite.texture = enemy_sprite.get("dead")
		enemy_death.emit(self)

func _input(ev):
	if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT:
		if ev.pressed and mouse_on_sprite and health > 0:
			health -= get_parent().level if "level" in get_parent() else 1
			if "experience" in get_parent():
				get_parent().experience += 1
			
			var click_time := Time.get_unix_time_from_system()
			latest_click = click_time
			$Sprite.texture = enemy_sprite.get("hurt")
			
			await get_tree().create_timer(0.2).timeout
			if click_time == latest_click and health > 0:
				$Sprite.texture = enemy_sprite.get("normal")


func _on_enemy_mouse_entered():
	mouse_on_sprite = true

func _on_enemy_mouse_exited():
	mouse_on_sprite = false
