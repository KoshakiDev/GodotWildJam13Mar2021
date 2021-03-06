extends Area2D


export(String, FILE, "*.tscn") var next_level_scene: String


func _ready():
	if not next_level_scene:
		printerr("No next_level set in LevelChanger %s" % name)


func _on_LevelChanger_body_entered(body):
	if body is Player:
		var next_level = load(next_level_scene).instance()
		if next_level is Level:
			Globals.change_level(next_level)
		else:
			printerr("next_level in LevelChanger %s is not a level scene." % name)
