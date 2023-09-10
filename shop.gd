extends Node2D

var shop_entry = preload("res://shop_button.tscn")

var gold := 0

func _ready():
	var item := shop_entry.instantiate()
	item.find_child("Item").text = "Example item"
	add_child(item)

func _process(_delta):
	gold = get_parent().find_child("Enemy_screen").gold
	
	var screen := get_viewport_rect().size
	$Background.size.x = screen.x
	$Background.size.y = screen.y - 300
	
	var gs_width = $GoldSprite.texture.get_width() * $GoldSprite.scale.x
	$Gold.position.x = (screen.x / 2) - ($Gold.size.x / 2) - (gs_width / 2)
	$GoldSprite.position.x = $Gold.position.x + $Gold.size.x + 12
	$Gold.text = "%s Gold" % gold
	
