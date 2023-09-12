extends Node2D

signal gold_change

var shop_item = preload("res://shop_item.tscn")

var bought_items = []

func _ready():
	var item := shop_item.instantiate()
	item.i_name = "Example item"
	item.price = 3
	item.connect("buy", buy)
	add_child(item)

func _process(_delta):
	var screen := get_viewport_rect().size
	$Background.size.x = screen.x
	$Background.size.y = screen.y - 290
	
	var gs_width = $GoldSprite.texture.get_width() * $GoldSprite.scale.x
	$Gold.text = "%s Gold" % get_parent().gold
	$Gold.size = $Gold.get_theme_font("font").get_string_size($Gold.text)
	$Gold.position.x = (screen.x / 2) - ($Gold.size.x / 2) - (gs_width / 2)
	$GoldSprite.position.x = $Gold.position.x + $Gold.size.x + 12

func buy(item, price):
	gold_change.emit(price)
	
	var arr = bought_items.filter(func(i): return i.name != item.name)
	arr.push_back(item)
	bought_items = arr
