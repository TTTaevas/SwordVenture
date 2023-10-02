extends Node2D

var categories = [
	{"name": "swords", "sprite": "res://sprites/icons/sword.png", "required_level": 2},
	{"name": "scrolls", "sprite": "res://sprites/icons/scroll.png", "required_level": 5},
	{"name": "potions", "sprite": "res://sprites/icons/potion.png", "required_level": 10},
	{"name": "magic", "sprite": "res://sprites/icons/spark.png", "required_level": 30},
]

var items = [
	{"category": "swords", "price": 5, "dps": 1, "level_multi": 1, "i_name": "Wooden Stick",
	"i_description": "A weird stick an old man sold you. It looks very fragile."},
	{"category": "swords", "price": 50, "dps": 3, "level_multi": 2, "i_name": "Stone Sword",
	"i_description": "Two rocks assembled on a stick. It's very cubic."},
	{"category": "swords", "price": 250, "dps": 7, "level_multi": 3, "i_name": "Iron Sword",
	"i_description": "Forged by a blacksmith amateur. You'll have to deal with it."},
	{"category": "swords", "price": 800, "dps": 20, "level_multi": 4, "i_name": "Ruby Sword",
	"i_description": "Shines like blood. Is it even made with Ruby?"},
	{"category": "swords", "price": 3000, "dps": 60, "level_multi": 5, "i_name": "Fire Sword",
	"i_description": "A magical sword made of fire. Useful to cook some skeletons."},
	{"category": "swords", "price": 11037, "dps": 135, "level_multi": 6, "i_name": "Sapphire Sword",
	"i_description": "Infused with magic, this sword shoots waves."},
	{"category": "swords", "price": 23500, "dps": 240, "level_multi": 7, "i_name": "Ice Sword",
	"i_description": "Makes the coins your foes turn into become almost too cold to pick up."},
	{"category": "swords", "price": 40000, "dps": 400, "level_multi": 8, "i_name": "VERY Sharp Sword",
	"i_description": "Really cool-looking, but its blade is so edgy it renders any sheath useless..."},
	{"category": "swords", "price": 100000, "dps": 1000, "level_multi": 9, "i_name": "Titan Sword",
	"i_description": "You stole this sword from a mighty Titan. Well done."},
	{"category": "swords", "price": 180000, "dps": 1800, "level_multi": 10, "i_name": "Legendary Sword",
	"i_description": "Rumoured to be hidden in the Dark Forest's depths, it turns out those rumours were accurate."},
	{"category": "swords", "price": 200000, "dps": 3000, "level_multi": 37, "i_name": "Spectral Sword",
	"i_description": "PRACTICALLY UNUPGRADABLE due to its nature, but would it ever need upgrades anyway?"},
	{"category": "swords", "price": 275000, "dps": 2750, "level_multi": 12, "i_name": "King's Gift",
	"i_description": "You've defended a kingdom from the Skeleton Army, your heroism did not go unrewarded."},
	{"category": "swords", "price": 400000, "dps": 5000, "level_multi": 14, "i_name": "Earth Slayer",
	"i_description": "Said to have been sent from the skies to Earth, thereby scarring the planet."},
	{"category": "swords", "price": 750000, "dps": 8000, "level_multi": 16, "i_name": "Dwarves' Gem",
	"i_description": "Forged by the best forgers in the deepest depths of the planet with the best materials."},
	{"category": "swords", "price": 1400000, "dps": 16000, "level_multi": 18, "i_name": "The Gods' Demise",
	"i_description": "Specifically created to end the rule of the Gods, once and for all."},
	{"category": "swords", "price": 3000000, "dps": 40000, "level_multi": 20, "i_name": "Void Blade",
	"i_description": "It is said to have come from another galaxy and to hold the same power as a black hole."},
	
	{"category": "scrolls", "price": 200, "i_name": "Sword Wielding",
	"i_description": "Learn to wield more swords at once!",
	"effect": func(): PlayerVariables.max_equipped_swords += 1},
	{"category": "scrolls", "price": 500, "i_name": "Practicing Smarter",
	"i_description": "Learn to gain 50% more experience!",
	"effect": func(): PlayerVariables.xp_effects.push_front(1.5)},
	{"category": "scrolls", "price": 1250, "i_name": "Strength",
	"i_description": "Learn to deal 400% more damage when tapping enemies!",
	"effect": func(): PlayerVariables.tap_effects.push_front(4)},
	{"category": "scrolls", "price": 1875, "i_name": "Smithing Skills",
	"i_description": "Learn to be able to upgrade any sword more easily level-wise!",
	"effect": func(): for sword in find_children("Item*", "", true, false).filter(func(i): return i.category == "swords"):
		sword.level_multi = max(1, sword.level_multi - 1)
		},
	
	{"category": "potions", "level_to_show": 0, "price": 2000, "duration": 15 * 60, "i_name": "Potion of Experience",
	"i_description": "Doubles the XP you gain from monsters for 15 minutes!",
	"effect": func(): PlayerVariables.xp_effects.push_back(2),
	"expired_effect": func(): PlayerVariables.xp_effects.remove_at(PlayerVariables.xp_effects.find(2))},
	{"category": "potions", "level_to_show": 12, "price": 5000, "duration": 10 * 60, "i_name": "Witch's Beverage",
	"i_description": "For 10 minutes, monsters you kill will turn into 20% more gold!",
	"effect": func(): PlayerVariables.gold_effects.push_back(1.2),
	"expired_effect": func(): PlayerVariables.gold_effects.remove_at(PlayerVariables.gold_effects.find(1.2))},
	{"category": "potions", "level_to_show": 15, "price": 8500, "duration": 30 * 60, "i_name": "Envy's Blood",
	"i_description": "When tapping an enemy, inflict an additional amount of damage worth 1% of your gold, for 30 minutes!",
	"effect": func(): PlayerVariables.misc_effects.push_back("Envy's Blood"),
	"expired_effect": func(): PlayerVariables.misc_effects.remove_at(PlayerVariables.gold_effects.find("Envy's Blood"))},
	
	{"category": "magic", "price": 250000000 * (((PlayerVariables.ascends) * 50) + 1), "i_name": "Ascend",
	"i_description": "Reset your progress, but make the game easier to go through!",
	"effect": PlayerVariables.ascend},
]

var category_button_scene = preload("res://scenes/bottom/category_button.tscn")
var category_scene = preload("res://scenes/bottom/category.tscn")
var item_scene = preload("res://scenes/bottom/item.tscn")

func _ready():
	$Background.position = Vector2(0, 0)
	
	for cat in categories:
		var category = category_button_scene.instantiate()
		category.cat_name = cat["name"]
		category.icon = cat["sprite"]
		category.required_level = cat["required_level"]
		category.hide()
		add_child(category)
		
		var shop = category_scene.instantiate()
		shop.name = "Category_%s" % cat["name"]
		shop.category = cat["name"]
		shop.hide()
		add_child(shop)
		
		var filtered_items = items.filter(func(item): return item.category == cat["name"])
		for i in filtered_items:
			var item = item_scene.instantiate()
			item.name = "Item_%s" % i["i_name"]
			item.category = cat["name"]
			
			var keys = i.keys()
			for key in keys:
				item[key] = i[key]
			shop.find_child("VContainer", true, false).add_child(item)
		
		if len(filtered_items) > 0:
			var separator_h = TextureRect.new()
			separator_h.mouse_filter = separator_h.MOUSE_FILTER_IGNORE
			separator_h.texture = GradientTexture2D.new()
			separator_h.texture.gradient = Gradient.new()
			separator_h.texture.gradient.colors = PackedColorArray([Color(0,0,0,0), Color(0,0,0,0)])
			var separator_v = TextureRect.new()
			separator_v.mouse_filter = separator_h.mouse_filter
			separator_v.texture = GradientTexture2D.new()
			separator_v.texture.gradient = Gradient.new()
			separator_v.texture.gradient.colors = PackedColorArray([Color(0,0,0,0), Color(0,0,0,0)])
			
			# Cheat for horizontal scrollbar
			filtered_items.sort_custom(func(a, b): return len(a.i_description) > len(b.i_description))
			var l = filtered_items[0]
			var x = shop.find_children("Item_*", "", true, false)[0].get_theme_font("font").get_string_size(l.i_description).x
			separator_h.name = "Separator_%s-horizontal" % cat["name"]
			separator_h.texture.set_height(2)
			separator_h.texture.set_width(x + 600)
			shop.find_child("Container", true, false).add_child(separator_h)
			
			# Cheat for vertical scrollbar
			separator_v.name = "Separator_%s-vertical" % cat["name"]
			separator_v.texture.set_height(50 + (len(filtered_items) * 12))
			shop.find_child("VContainer", true, false).add_child(separator_v)

func _process(_delta):
	var screen := get_viewport_rect().size
	$Background.size.x = screen.x
	
	var x = min(max(0.20, screen.x / 1920), 1.00)
	var y = min(max(0.20, screen.y / 1920), 1.00)
	var s = min(max(0.20, min(x, y)), 1.00)
	$ShopBorder.scale = Vector2(s, s)
	$ShopBorder.size = ($Background.size / $ShopBorder.scale) - Vector2(50, 100 / (y + 0.2))
	$ShopBorder.position.x = ($Background.size.x / 2) - (($ShopBorder.size.x * $ShopBorder.scale.x) / 2)
	$ShopBorder.position.y = 20 + (s * 75)
	
	var i = $ShopBorder.patch_margin_left
	$ShopBackground.size = (($ShopBorder.size - Vector2(i * 2, i * 2)) * $ShopBorder.scale) + Vector2(2, 2)
	$ShopBackground.position = (($ShopBorder.position) + Vector2(i, i) * $ShopBorder.scale) - Vector2(2, 2)
	
	var magic_number = min(max(min(x * 3.5, y * 3.0), 0.75), 1)
	var shops = find_children("Category_*", "Control", true, false)
	for shop in shops.filter(func(shop): return shop.is_visible()):
		var container = shop.find_child("Container")
		container.size = $ShopBackground.size / magic_number
		container.scale = Vector2(magic_number, magic_number)
		container.position = $ShopBackground.position
		
	for shop in shops.filter(func(shop): return !shop.is_visible()):
		var container = shop.find_child("Container")
		container.size = Vector2(0, 0)
		container.position = Vector2(-1920, -1920)
	
	for index in len(categories):
		var cat = categories[index]
		var button = find_child("Cat_button_%s" % cat["name"], false, false)
		
		if (button.is_visible() == false and PlayerVariables.level >= button.required_level):
			button.show()
			var shortcut = Shortcut.new()
			var key_normal = InputEventKey.new()
			key_normal.set_physical_keycode(49 + index)
			var key_pad = InputEventKey.new()
			key_pad.set_physical_keycode(4194439 + index)
			shortcut.set_events([key_normal, key_pad])
			button.set_shortcut(shortcut)
		
		button.position.x = ($ShopBackground.position.x + 2) + ((button.size.x + 5) * index) * min((x * 3), 2)
		button.position.y = $ShopBorder.position.y - 18 + (($ShopBorder.scale.y - 0.75) * 18)
		
		var shop_container = shops.filter(func(s): return s.category == cat["name"])[0].find_child("VContainer", true, false)
		var shop_articles = shop_container.get_children().filter(func(a): return "Separator" not in a.name)
		for article_index in len(shop_articles):
			var article = shop_articles[article_index]
			article.position.x = 10
			article.position.y = 10 + (article_index * (article.size.y * 1.2))
		
		var shop_items = shop_articles.filter(func(a): return "Item" in a.name)
		for item in shop_items:
			if PlayerVariables.level >= item["level_to_show"]:
				item.show()
			else:
				item.hide()
	
	$Gold.text = "%s Gold" % PlayerVariables.displayNumber(PlayerVariables.gold)
	$Gold.size = $Gold.get_theme_font("font").get_string_size($Gold.text)
	var gs_width = $GoldSprite.texture.get_width() * $GoldSprite.scale.x
	var gold_x = (screen.x / 2) - ($Gold.size.x / 2) - (gs_width / 2)
	
	var buttons = find_children("Cat_button*", "", false, false).filter(func(b): return b.is_visible())
	if len(buttons):
		var btn = buttons[len(buttons) - 1]
		var offset = abs(max(0, (btn.position.x + (btn.size.x)) - gold_x))
		if offset < 5:
			gold_x += abs(max(0, (btn.position.x + (btn.size.x)) - gold_x))
		else:
			gold_x = screen.x - gs_width - $Gold.size.x - 10
	
	$Gold.position.x = gold_x
	$GoldSprite.position.x = $Gold.position.x + $Gold.size.x + 12
