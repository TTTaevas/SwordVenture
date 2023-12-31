extends Control

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	self.position.y = 0
	$LevelLabel.position.y = 10
	$ExperienceBar.position.y = $LevelLabel.size.y + $LevelLabel.position.y + 5
	$ExperienceLabel.position.y = ($ExperienceBar.size.y / 4) + $ExperienceBar.position.y - 2

func _process(_delta):
	global_position.x = (get_viewport_rect().size.x / 2) - (self.size.x)
	
	$ExperienceBar.value = PlayerVariables.experience
	$ExperienceBar.max_value = PlayerVariables.max_experience
	
	$ExperienceLabel.text = "%s / %s XP" % [
		PlayerVariables.displayNumber($ExperienceBar.value),
		PlayerVariables.displayNumber($ExperienceBar.max_value)
	]
	$LevelLabel.text = "Level %s" % PlayerVariables.displayNumber(PlayerVariables.level)
	$ExperienceLabel.size = $ExperienceLabel.get_theme_font("font").get_string_size($ExperienceLabel.text)
	$LevelLabel.size = $LevelLabel.get_theme_font("font").get_string_size($LevelLabel.text)
	
	$ExperienceBar.scale.x = max(1.2, (get_viewport_rect().size.x - $ExperienceBar.size.x) / 250)
	$LevelLabel.position.x = (self.size.x / 2) - ($LevelLabel.size.x / 2)
	$ExperienceBar.position.x = (self.size.x / 2) - (($ExperienceBar.size.x * $ExperienceBar.scale.x) / 2)
	$ExperienceLabel.position.x = (self.size.x / 2) - ($ExperienceLabel.size.x / 2)
