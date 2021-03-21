extends Control

const LEVEL_PATH = "res://Source/Levels/Level 1.tscn"

func _on_StartButton_pressed():
	SaveManager.reset_saves()
	Globals.change_level(preload(LEVEL_PATH).instance())


func _on_ContinueButton_pressed():
	Globals.change_level(preload(LEVEL_PATH).instance())
