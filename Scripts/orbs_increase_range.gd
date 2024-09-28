extends Area2D
class_name Increase_Range_Orb

@onready var spaceship: CharacterBody2D = $"../../Spaceship"

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	rotation_degrees += 0.2 * delta

#call add health method and remove object upon impact with player
func _on_body_entered(body: Node2D) -> void:
	var sp_range : float = 20
	if body.is_in_group("player"):
		spaceship.increase_sp_range(sp_range)
		queue_free()
