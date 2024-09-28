extends Area2D
class_name Increase_Steering_Orb

@onready var spaceship: CharacterBody2D = $"../../Spaceship"

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	rotation_degrees += 0.2 * delta

#call add health method and remove object upon impact with player
func _on_body_entered(body: Node2D) -> void:
	var steer : float = 0.5
	if body.is_in_group("player"):
		spaceship.increase_steering(steer)
		queue_free()
