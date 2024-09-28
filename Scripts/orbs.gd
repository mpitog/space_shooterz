extends Area2D
class_name Health_Orb

#var enemy = preload("res://Scenes/enemy.tscn")
const spaceship = preload("res://Scenes/player_spaceship.tscn")

func _ready() -> void:
	pass
	#orb_pos()
	#print(get_viewport().get_visible_rect().size)

#instanciate a health orb when enemy dies with low chance
#func orb_pos():
	#var viewport_rect: Rect2 = get_viewport().get_visible_rect()
	#position = Vector2 (randi_range(viewport_rect.position.x, viewport_rect.position.x + viewport_rect.size.x),randi_range(viewport_rect.position.y, viewport_rect.position.y + viewport_rect.size.y))
	#position = Vector2(305.0,485.0)
	#print(position)
	
func _process(delta: float) -> void:
	rotation_degrees += 0.5 * delta

#call add health method and remove object upon impact with player
func _on_body_entered(body: Node2D) -> void:
	var health_to_add : int = 1
	if body.is_in_group("player"):
		get_parent().get_parent().get_node("Spaceship").add_health(health_to_add)
		queue_free()
