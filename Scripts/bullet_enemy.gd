extends Area2D
class_name Enemy_BUllet

var en_bullet_speed : float
var en_bullet_damage : int
var en_travelled_distance :float = 0
var en_max_range : float
var bulletcount : int = 0
var on_target_bulletcount : int = 0
@onready var spaceship: CharacterBody2D = $"../Spaceship"


func _ready() -> void:
	en_bullet_damage = 1 # need to fix this and get access to boss node
	en_bullet_speed = 200 # need to fix this and get access to boss node
	en_max_range = 400 # need to fix this and get access to boss node
	
func _physics_process(delta):
	var direction = Vector2.DOWN.rotated(rotation)
	position += direction * en_bullet_speed * delta 
	en_travelled_distance += en_bullet_speed * delta
	if en_travelled_distance > en_max_range:
		modulate.a = move_toward(1,0.5,0.5)
		if modulate.a == 0.5:
			queue_free()
	if position.y < 10:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		spaceship.player_take_damage(en_bullet_damage)
		self.queue_free()
