extends Position2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var force_field_scene: PackedScene
onready var timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	var force_field = force_field_scene.instance()
	force_field.global_position = global_position
	get_tree().get_root().add_child(force_field)
