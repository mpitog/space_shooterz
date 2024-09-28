extends Area2D
class_name BasicBulletBack

var bullet_speed : float
var bullet_damage : int
var travelled_distance :float = 0
var max_range : float
var pass_through_enemies : int = 2
var bulletcount : int = 0
var on_target_bulletcount : int = 0
@onready var spaceship: CharacterBody2D = $"../Spaceship"
@onready var enemies_mob: Node2D = $"../Enemies_mob"

const BOSS = preload("res://Scenes/boss.tscn")
var boss = BOSS.instantiate()

func _ready() -> void:
	bullet_damage = spaceship.strength - (0.95 * spaceship.strength)
	bullet_speed = spaceship.attack_speed * 2
	max_range = spaceship.sp_range
	rotation_degrees = randf_range(-15,15)

func _physics_process(delta):
	var direction = Vector2.DOWN.rotated(rotation)
	position += direction * bullet_speed * delta
	travelled_distance += bullet_speed * delta
	if travelled_distance > max_range:
		modulate.a = move_toward(1,0.5,1)
		if modulate.a == 0.5:
			queue_free()
	if position.y < 10:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		on_target_bulletcount += 1
		pass_through_enemies -= 10
		if pass_through_enemies <= 0:
			queue_free() 
