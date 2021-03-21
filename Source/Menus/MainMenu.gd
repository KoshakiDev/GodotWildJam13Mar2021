extends Control



func _ready():
	if not Globals.last_played_level:
		$VBoxContainer/ContinueButton.disabled = true

func _on_StartButton_pressed():
	SaveManager.reset_saves()
	Globals.change_level(load("res://Source/Levels/Levels/SaveTestLevel.tscn").instance())


func _on_ContinueButton_pressed():
	Globals.change_level(Globals.last_played_level.instance())
