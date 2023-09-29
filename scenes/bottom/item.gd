extends TextureButton

var game_clock := 0.0

# Universal
var psed := false
var i_name: String
var i_description: String
var category: String
var price: int

# Swords
var psed_equip := false
var current_dps := 0
var dps: int
var original_dps: int
var level := 0
var level_multi := 1
var equipped := false

# Potions
var duration: int
var duration_left := 0
var level_to_show: int
var effect: Callable
var expired_effect: Callable

func _ready():
	$Name.text = i_name
	$Description.text = i_description
	original_dps = dps
	
	if category == "potions":
		self.texture_normal = load("res://sprites/shop/button-yellow.png")
		self.texture_pressed = load("res://sprites/shop/button-yellow-pressed.png")
	elif category == "scrolls":
		self.texture_normal = load("res://sprites/shop/button-red.png")
		self.texture_pressed = load("res://sprites/shop/button-red-pressed.png")

func _process(delta):
	game_clock += delta
	if int(game_clock) != 0:
		game_clock = 0
		if duration_left > 0:
			duration_left -= 1
			if duration_left <= 0:
				expired_effect.call()
	
	$Progress.value = min(100, (PlayerVariables.gold / price) * 100)
	if PlayerVariables.gold < price or duration_left > 0 or (level * level_multi) + 1 > PlayerVariables.level:
		disabled = true
	elif disabled == true:
		disabled = false
	
	if disabled:
		mouse_default_cursor_shape = Control.CURSOR_ARROW
		$Progress.show()
	else:
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		$Progress.hide()
	
	if category != "swords" or level <= 0:
		$Equip.hide()
	
	if level < 1:
		$Price.text = "Buy: %s" % PlayerVariables.displayNumber(price)
		if category == "swords":
			$Stats.text = "Once equipped, it is able to deal %s damage per second!" % PlayerVariables.displayNumber(dps)
		else:
			$Stats.text = ""
	else:
		if category == "swords":
			$Equip.show()
			$Price.text = "Upgrade: %s" % PlayerVariables.displayNumber(price)
			$Stats.text = "Does %s dps, will do %s if you upgrade it! Requires Level %s." % [current_dps, dps, (level * level_multi) + 1]
		elif category == "potions":
			$Price.text = "New price: %s" % PlayerVariables.displayNumber(price)
			$Stats.text = "%s left!" % translate_time(duration_left)
		else:
			$Price.text = "Buy: %s" % PlayerVariables.displayNumber(price)
	
	$Name.position.x = (size.x / 2) - ($Name.size.x / 2)
	var gs_width = $GoldSprite.texture.get_width() * $GoldSprite.scale.x
	$Price.size = $Price.get_theme_font("font").get_string_size($Price.text)
	$Price.position.x = (size.x / 2) - ($Price.size.x / 2) - (gs_width / 2)
	$GoldSprite.position.x = $Price.position.x + $Price.size.x + 12
	
	$Description.size = $Description.get_theme_font("font").get_string_size($Description.text)
	$Description.position.x = size.x + (150 if category == "swords" and level > 0 else 10)
	$Description.position.y = 15
	
	$Stats.size = $Stats.get_theme_font("font").get_string_size($Stats.text)
	$Stats.position.x = size.x + (150 if category == "swords" and level > 0 else 10)
	$Stats.position.y = 35
	
	var children_on_button := get_children().filter(func(c): return c.name in ["Name", "Price", "GoldSprite"])
	if button_pressed and psed == false:
		psed = true
		for i in children_on_button:
			i.position.y += 5
	elif button_pressed == false and psed:
		psed = false
		for i in children_on_button:
			i.position.y -= 5
	
	if equipped == false:
		$Equip/Action.text = "Equip!"
	else:
		$Equip/Action.text = "Unequip!"
	$Equip/Action.size = $Equip/Action.get_theme_font("font").get_string_size($Equip/Action.text)
	$Equip/Action.position.x = ($Equip.size.x - $Equip/Action.size.x) / 2
		
	if $Equip.button_pressed and psed_equip == false:
		psed_equip = true
		$Equip/Action.position.y += 5
	elif $Equip.button_pressed == false and psed_equip:
		psed_equip = false
		$Equip/Action.position.y -= 5

func _pressed():
	$SoundBuy.play()
	level += 1
	PlayerVariables.gold -= price
	
	if category == "swords":
		var arr = PlayerVariables.swords.filter(func(s): return s.i_name != self.i_name)
		arr.push_back({"i_name": self.i_name, "dps": self.dps, "equipped": self.equipped})
		PlayerVariables.swords = arr
		
		price = ceil(price * 1.07)
		current_dps = dps
		dps += original_dps
		
	elif category == "potions":
		price = ceil(price * 8.60)
		duration_left = duration
		effect.call()
	
	elif category == "scrolls":
		price = ceil(price * 20.50)
		effect.call()

func _on_equip_pressed():
	if not equipped:
		if len(PlayerVariables.swords.filter(func(s): return s.equipped)) + 1 <= PlayerVariables.max_equipped_swords:
			$Equip/SoundEquip.play()
			equipped = true
	else:
		$Equip/SoundUnequip.play()
		equipped = false
	
	var arr = PlayerVariables.swords.filter(func(s): return s.i_name != self.i_name)
	arr.push_back({"i_name": self.i_name, "dps": self.current_dps, "equipped": self.equipped})
	PlayerVariables.swords = arr

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
