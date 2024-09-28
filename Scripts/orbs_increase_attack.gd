extends Area2D
class_name Increase_Attack_Power_Orb

@onready var spaceship: CharacterBody2D = $"../../Spaceship"

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	rotation_degrees -= 0.5 * delta

#call add health method and remove object upon impact with player
func _on_body_entered(body: Node2D) -> void:
	var att_strength : int = 1
	if body.is_in_group("player"):
		spaceship.increase_attack_strength(att_strength)
		queue_free()
