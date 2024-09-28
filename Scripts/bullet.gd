extends Area2D
class_name BasicBullet

var bullet_speed : float
var bullet_damage : int
var travelled_distance :float = 0
var max_range : float
var pass_through_enemies : int = 2
var bulletcount : int = 0
var on_target_bulletcount : int = 0

const BOSS = preload("res://Scenes/boss.tscn")

@onready var spaceship: CharacterBody2D = $"../Spaceship"
#@onready var enemy: Base_enemy = $"../Enemies_mob/Enemy"
@onready var boss: Boss_Phobos = BOSS.instantiate()

func _ready() -> void:
	bullet_damage = spaceship.strength
	bullet_speed = spaceship.attack_speed
	max_range = spaceship.sp_range
	
func _physics_process(delta):
	var direction = Vector2.UP.rotated(rotation)
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
		pass_through_enemies -= 1
		#enemy.enemy_take_damage(bullet_damage)
		if pass_through_enemies <= 0:
			queue_free()

func _on_area_entered_boss_shield(area: Area2D) -> void:
	if area.is_in_group("shield_area") and area.visible == true:
		queue_free()
