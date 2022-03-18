extends ViewportContainer

onready var viewport = get_node("Viewport")

func _ready():
	set_process_input(true)

func _gui_input(event: InputEvent) -> void:
	viewport.unhandled_input(event)
