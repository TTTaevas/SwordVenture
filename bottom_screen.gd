extends Node2D

signal gold_change

var categories = [
	{"name": "swords", "sprite": "res://sprites/icons/sword.png", "level_required": 1},
	{"name": "potions", "sprite": "res://sprites/icons/potion.png", "level_required": 4},
	{"name": "scrolls", "sprite": "res://sprites/icons/scroll.png", "level_required": 10},
	{"name": "enchantments", "sprite": "res://sprites/icons/spark.png", "level_required": 20},
]
var shop_category = preload("res://shop_category.tscn")

var items = [
	{"name": "test 1", "price": 5, "dps": 3, "category": "swords"},
	{"name": "test 2", "price": 4, "dps": 2, "category": "swords"},
	{"name": "test 3", "price": 6, "dps": 4, "category": "potions"},
	{"name": "test 4", "price": 6, "dps": 4, "category": "potions"},
	{"name": "test 5", "price": 6, "dps": 4, "category": "potions"},
]
var shop_item = preload("res://shop_button.tscn")

var shop_selling = preload("res://shop.tscn")

var bought_items = []

func _ready():
	$Background.position = Vector2(0, 0)
	
	for cat in categories:
		var category = shop_category.instantiate()
		category.cat_name = cat["name"]
		category.icon = cat["sprite"]
		category.position.x = cat["level_required"] * 10
		add_child(category)
		
		var shop = shop_selling.instantiate()
		shop.name = "shop_selling_%s" % cat["name"]
		shop.category = cat["name"]
		shop.hide()
		add_child(shop)
		
		var id = 0
		var filtered_items = items.filter(func(item): return item.category == cat["name"])
		for i in filtered_items:
			id += 1
		
			var item = shop_item.instantiate()
			item.name = "item_%s" % id
			item.i_name = i["name"]
			item.price = i["price"]
			item.dps = i["dps"]
			item.connect("buy", buy)
			shop.find_child("VContainer", true, false).add_child(item)
			
			# Cheat for scrollbar
			var separator = TextureRect.new()
			separator.name = "separator_%s" % id
			separator.texture = GradientTexture2D.new()
			separator.texture.set_height(10 if id != len(filtered_items) else 30)
			separator.texture.gradient = Gradient.new()
			separator.texture.gradient.colors = PackedColorArray([Color(0,0,0,0), Color(0,0,0,0)])
			shop.find_child("VContainer", true, false).add_child(separator)


func _process(_delta):	
	var screen := get_viewport_rect().size
	$Background.size.x = screen.x
	$Background.size.y = screen.y - 290
	
	var gs_width = $GoldSprite.texture.get_width() * $GoldSprite.scale.x
	$Gold.text = "%s Gold" % get_parent().gold
	$Gold.size = $Gold.get_theme_font("font").get_string_size($Gold.text)
	$Gold.position.x = (screen.x / 2) - ($Gold.size.x / 2) - (gs_width / 2)
	$GoldSprite.position.x = $Gold.position.x + $Gold.size.x + 12
	
	var s = min(max(0.65, $Background.size.x / 1920), 1)
	$ShopBorder.scale = Vector2(s, s)
	$ShopBorder.size = ($Background.size / $ShopBorder.scale) - Vector2(100, 100)
	$ShopBorder.position.x = ($Background.size.x / 2) - (($ShopBorder.size.x * $ShopBorder.scale.x) / 2)
	$ShopBorder.position.y = 50
	
	var i = $ShopBorder.patch_margin_left
	$ShopBackground.size = ($ShopBorder.size - Vector2(i * 2, i * 2)) * $ShopBorder.scale
	$ShopBackground.position = ($ShopBorder.position) + Vector2(i, i) * $ShopBorder.scale
	
	var shops = find_children("shop_selling*", "Control", true, false)
	for shop in shops.filter(func(shop): return shop.is_visible()):
		var container = shop.find_child("Container")
		container.size = $ShopBackground.size
		container.position = $ShopBackground.position
		
	for shop in shops.filter(func(shop): return !shop.is_visible()):
		var container = shop.find_child("Container")
		container.size = Vector2(0, 0)
		container.position = Vector2(-1920, -1920)
	
	for cat in categories:
		var items = shops.filter(func(s): return s.category == cat["name"])[0].find_children("item*", "Control", true, false)
		for index in len(items):
			var item = items[index]
			item.position.x = 10
			item.position.y = 10 + (index * (item.size.y * 1.2))

func buy(item, price):
	gold_change.emit(price)
	
	var arr = bought_items.filter(func(i): return i.name != item.name)
	arr.push_back(item)
	bought_items = arr
