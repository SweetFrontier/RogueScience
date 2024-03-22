extends Node


var currentLevel : int = 1
var unlockedLevel : int = 0
var numLevels : int = 40

func _ready():
	var save_file = FileAccess.open("user://rogue_science.save", FileAccess.READ)
	if (save_file != null):
		unlockedLevel = save_file.get_as_text().to_int()
		currentLevel = unlockedLevel+1
		if currentLevel > numLevels:
			currentLevel = numLevels

func give_free_cookies():
	var save_file = FileAccess.open("user://rogue_science.save", FileAccess.WRITE)
	save_file.store_string("%s" % unlockedLevel)

