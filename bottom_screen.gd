extends Node2D

signal gold_change

var categories = [
	{"name": "swords", "sprite": "res://sprites/icons/sword.png", "required_level": 2}, #2
	{"name": "potions", "sprite": "res://sprites/icons/potion.png", "required_level": 4}, #4
	{"name": "scrolls", "sprite": "res://sprites/icons/scroll.png", "required_level": 10}, #10
	{"name": "enchantments", "sprite": "res://sprites/icons/spark.png", "required_level": 20}, #20
]
var shop_category = preload("res://shop_category.tscn")

var items = [
	{"category": "swords", "price": 5, "dps": 1, "name": "Wooden Stick", #5 #1
	"description": "A weird stick an old man sold you. It looks very fragile."},
	{"category": "swords", "price": 30, "dps": 3, "name": "Stone Sword", #30
	"description": "Two rocks assembled on a stick. It's very cubic."},
	{"category": "swords", "price": 100, "dps": 7, "name": "Iron Sword",
	"description": "Forged by a blacksmith amateur. You'll have to deal with it."},
	{"category": "swords", "price": 800, "dps": 20, "name": "Ruby Sword",
	"description": "Shines like blood. Is it even made with Ruby?"},
	{"category": "swords", "price": 3000, "dps": 60, "name": "Fire Sword",
	"description": "A magical sword made of fire. Useful to cook some skeletons."},
	{"category": "swords", "price": 12000, "dps": 150, "name": "Sapphire Sword",
	"description": "Infused with magic, this sword shoots waves."},
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
		category.required_level = cat["required_level"]
		category.hide()
		add_child(category)
		
		var shop = shop_selling.instantiate()
		shop.name = "Shop_selling_%s" % cat["name"]
		shop.category = cat["name"]
		shop.hide()
		add_child(shop)
		
		var id = 0
		var filtered_items = items.filter(func(item): return item.category == cat["name"])
		for i in filtered_items:
			id += 1
		
			var item = shop_item.instantiate()
			item.name = "item_%s" % id
			item.category = cat["name"]
			item.i_name = i["name"]
			item.i_description = i["description"]
			item.price = i["price"]
			item.dps = i["dps"]
			item.connect("buy", buy)
			shop.find_child("VContainer", true, false).add_child(item)
			
			# Cheat for vertical scrollbar
			var separator = TextureRect.new()
			separator.z_index = -10
			separator.name = "separator_%s" % id
			separator.texture = GradientTexture2D.new()
			separator.texture.set_height(10 if id != len(filtered_items) else 60)
			separator.texture.gradient = Gradient.new()
			separator.texture.gradient.colors = PackedColorArray([Color(0,0,0,0), Color(0,0,0,0)])
			shop.find_child("VContainer", true, false).add_child(separator)
		
		# Cheat for horizontal scrollbar
		if len(filtered_items) > 0:
			filtered_items.sort_custom(func(a, b): return len(a.description) > len(b.description))
			var l = filtered_items[0]
			var x = shop.find_children("item_*", "", true, false)[0].get_theme_font("font").get_string_size(l.description).x
			var separator = TextureRect.new()
			separator.z_index = -10
			separator.name = "separator_horizontal"
			separator.texture = GradientTexture2D.new()
			separator.texture.set_width(x * 2)
			separator.texture.set_height(1)
			separator.texture.gradient = Gradient.new()
			separator.texture.gradient.colors = PackedColorArray([Color(0,0,0,0), Color(0,0,0,0)])
			shop.find_child("Container", true, false).add_child(separator)

func _process(_delta):
	var screen := get_viewport_rect().size
	$Background.size.x = screen.x
	$Background.size.y = screen.y - 290
	
	var gs_width = $GoldSprite.texture.get_width() * $GoldSprite.scale.x
	$Gold.text = "%s Gold" % PlayerVariables.gold
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
	
	var shops = find_children("Shop_selling_*", "Control", true, false)
	for shop in shops.filter(func(shop): return shop.is_visible()):
		var container = shop.find_child("Container")
		container.size = $ShopBackground.size
		container.position = $ShopBackground.position
		
	for shop in shops.filter(func(shop): return !shop.is_visible()):
		var container = shop.find_child("Container")
		container.size = Vector2(0, 0)
		container.position = Vector2(-1920, -1920)
	
	for e in len(categories):
		var cat = categories[e]
		var button = find_child("Shop_category_%s" % cat["name"], false, false)
		
		if (button.is_visible() == false and PlayerVariables.level >= button.required_level):
			button.show()
		
		var x = $ShopBackground.position.x * (e + 1)
		if len(categories) * button.size.x >= $ShopBackground.size.x - 10 and e != 0:
			x -= (button.size.x / 2) * e
		button.position.x = x
		button.position.y = $ShopBorder.position.y - 18 + (($ShopBorder.scale.y - 0.75) * 18)
		
		var shop_items = shops.filter(func(s): return s.category == cat["name"])[0].find_child("VContainer", true, false).get_children().filter(func(i): return "separator" not in i.name)
		for index in len(shop_items):
			var item = shop_items[index]
			item.position.x = 10
			item.position.y = 10 + (index * (item.size.y * 1.2))

func buy(item):
	gold_change.emit(item.price)
	
	var arr = bought_items.filter(func(i): return i.name != item.name)
	arr.push_back(item)
	bought_items = arr
