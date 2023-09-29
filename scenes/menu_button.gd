extends TextureButton

var action: String
var description: String
var callable: Callable

func _ready():
	if action != "" and description != "":
		name = "%sButton" % action
		$Action.text = action
		$Description.text = description

func _process(_delta):
	if disabled:
		mouse_default_cursor_shape = Control.CURSOR_ARROW
	else:
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
	$Action.size = $Action.get_theme_font("font").get_string_size($Action.text)
	$Description.size = $Description.get_theme_font("font").get_string_size($Description.text)
	$Action.position.x = (size.x - $Action.size.x) / 2
	$Description.position.x = (size.x - $Description.size.x) / 2
	$Action.position.y = 15 if button_pressed else 10
	$Description.position.y = 38 if button_pressed else 33

func _pressed():
	$SoundSelect.play()
	$Description.text = await callable.call()
	await get_tree().create_timer(2).timeout
	$Description.text = description
