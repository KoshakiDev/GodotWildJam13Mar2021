extends Area2D

export var thrust_force = 300

export var moving_speed = 5000

onready var timer = $Delete

func _ready():
	timer.start()
	

func _physics_process(delta):
	position.y += delta * moving_speed

func _on_KnockbackArea_body_entered(body):
	var impulse:Vector2 = body.global_position - self.global_position
	impulse = impulse.normalized() * thrust_force
	body.linear_velocity = Vector2.ZERO
	body.apply_central_impulse(impulse)
	


func _on_Delete_timeout():
	queue_free()
	
