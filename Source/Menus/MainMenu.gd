extends Control

const LEVEL_PATH = "res://Source/Levels/Levels/Level1.tscn"
const LEVEL_PATH2 = "res://Source/Levels/Levels/SaveTestLevel.tscn"


func _ready():
	if not Globals.last_played_level:
		$VBoxContainer/ContinueButton.disabled = true

func _on_StartButton_pressed():
	SaveManager.reset_saves()
	
	Globals.change_level(preload(LEVEL_PATH).instance())


func _on_ContinueButton_pressed():
	Globals.change_level(Globals.last_played_level.instance())
