extends Control



func _on_StartButton_pressed():
	SaveManager.reset_saves()
	Globals.change_level(preload("res://Source/Levels/SaveTestLevel.tscn").instance())


func _on_ContinueButton_pressed():
	Globals.change_level(preload("res://Source/Levels/SaveTestLevel.tscn").instance())
