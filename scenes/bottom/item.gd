extends TextureButton

# Universal
var psed := false
var i_name: String
var i_description: String
var category: String
var price: int

# Swords
var current_dps := 0
var dps: int
var original_dps: int
var level := 0

# Potions
var duration: int
var duration_left := 0
var effect: Callable
var expired_effect: Callable

func _ready():
	$Name.text = i_name
	$Description.text = i_description
	original_dps = dps
	
	if category == "potions":
		self.texture_normal = load("res://sprites/shop/button-yellow.png")
		self.texture_pressed = load("res://sprites/shop/button-yellow-pressed.png")

func _process(_delta):
	if PlayerVariables.gold < price or duration_left > 0 or level + 1 > PlayerVariables.level:
		disabled = true
	elif disabled == true:
		disabled = false
	
	if level < 1:
		$Price.text = "Buy: %s" % price
		if category == "swords":
			$Stats.text = "Once equipped, it is able to deal %s damage per second!" % dps
		else:
			$Stats.text = ""
	else:
		if category == "swords":
			$Price.text = "Upgrade: %s" % price
			$Stats.text = "Does %s dps, will do %s if you upgrade it! Requires Level %s." % [current_dps, dps, level + 1]
		else:
			$Price.text = "New price: %s" % price
			$Stats.text = "%s left!" % translate_time(duration_left)
	
	$Name.position.x = (size.x / 2) - ($Name.size.x / 2)
	var gs_width = $GoldSprite.texture.get_width() * $GoldSprite.scale.x
	$Price.size = $Price.get_theme_font("font").get_string_size($Price.text)
	$Price.position.x = (size.x / 2) - ($Price.size.x / 2) - (gs_width / 2)
	$GoldSprite.position.x = $Price.position.x + $Price.size.x + 12
	
	$Description.size = $Description.get_theme_font("font").get_string_size($Description.text)
	$Description.position.x = size.x + 10
	$Description.position.y = 15
	
	$Stats.size = $Stats.get_theme_font("font").get_string_size($Stats.text)
	$Stats.position.x = size.x + 10
	$Stats.position.y = 35
	
	var children_on_button := get_children().filter(func(c): return c.name != "Stats" and c.name != "Description")
	if button_pressed and psed == false:
		psed = true
		for i in children_on_button:
			i.position.y += 5
	elif button_pressed == false and psed:
		psed = false
		for i in children_on_button:
			i.position.y -= 5

func _pressed():
	level += 1
	PlayerVariables.gold -= price
	
	if category == "swords":
		var arr = PlayerVariables.swords.filter(func(i): return i.i_name != self.i_name)
		arr.push_back({"i_name": self.i_name, "dps": self.dps})
		PlayerVariables.swords = arr
		
		price = ceil(price * 1.07)
		current_dps = dps
		dps += original_dps
	elif category == "potions":
		price = ceil(price * 8.60)
		duration_left = duration
		effect.call()
		for i in duration_left:
			await get_tree().create_timer(1).timeout
			duration_left -= 1
			if i + 1 == duration:
				expired_effect.call()
				level -= 1

func translate_time(seconds: int):
	var m := 0
	var s = 0
	
	var i = seconds
	while i >= 60:
		m += 1
		i -= 60
	while i > 0:
		s += 1
		i -= 1
	
	var se = ("0%s" % s) if s < 10 else str(s) 
	return "%s:%s" % [m, se]
