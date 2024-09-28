extends Area2D
class_name Boss_Phobos

var boss_score : int = 50
var boss_level : int = 1
var boss_health : int = 10
var boss_damage : int = 1
var boss_att_speed : float = 200
var shooting_counter : int = 0
var boss_range : int = 600
var cooldown : float
enum BossType { EASY, NORMAL, HARD }
var boss_type
var velocity : Vector2 = Vector2(0,0)
var is_boss_shooting : bool = false
@onready var shooter_right: Marker2D = $Shooter_right
@onready var shooter_left: Marker2D = $Shooter_left
@onready var cooldown_timer: Timer = $Cooldown_timer
@onready var cycle_timer: Timer = $cycle_timer
@onready var boss_explosion: CPUParticles2D = $boss_explosion
@onready var main: Node2D = $"../.."
#@onready var basic_bullet: BasicBullet = $"../../Basic_Bullet"
#@onready var basic_bullet_back: BasicBulletBack = $"../../Basic_Bullet_back"
@onready var shield_area: Area2D = $shield_area
@onready var spaceship: CharacterBody2D = $"../../Spaceship"
@onready var back_gun_chest: Area2D = $"../../BackGunChest"
@onready var multi_gun_chest_front: Area2D = $"../../MultiGunChestFront"


func _ready() -> void:
	var chance_to_easy : int = randi_range(1,2)
	var chance_to_normal : int = randi_range(1,2)
	var chance_to_hard : int = randi_range(2,30)
	if chance_to_easy == 1 and chance_to_normal!=1:
		boss_type = BossType.EASY
		boss_score = 50
		boss_level = 1
		boss_health = 10
		boss_damage = 1
		boss_att_speed = 200
		boss_range = 600
	elif chance_to_normal == 1 and chance_to_easy!=1:
		boss_type = BossType.NORMAL
		boss_score = 100
		boss_level = 2
		boss_health = 20
		boss_damage = 2
		boss_att_speed = 300
		boss_range = 800
	elif chance_to_hard ==1:
		boss_type = BossType.HARD #needs to be set up
	#position = Vector2(150,25)
	#chance_to_hold_orb()  --> need to fix func lower below first

func _physics_process(delta: float) -> void:
	if boss_type == BossType.EASY:
		velocity += Vector2(1,15)
		position.y = velocity.y * delta
		position.x = move_toward(position.x, spaceship.global_position.x, 0.5)
	elif  boss_type == BossType.NORMAL:
		velocity += Vector2(1.5,25)
		position.y = velocity.y * delta
		position.x = move_toward(position.x, spaceship.global_position.x, 0.7)
		modulate = Color(0.1,1,1,1)
	elif boss_type == BossType.HARD:
		pass


func boss_shoot():
	const ENEMY_BULLET = preload("res://Scenes/bullet_enemy.tscn")
	if shooter_right and is_boss_shooting == true:
		var new_enemy_bullet = ENEMY_BULLET.instantiate()
		# Set the bullet's position and rotation to match the shooter
		new_enemy_bullet.global_position = shooter_right.global_position
		#new_enemy_bullet.global_rotation = shooter_right.global_rotation
		# Add the bullet to the parent of the shooter or to the main scene
		get_tree().current_scene.add_child(new_enemy_bullet)
	if shooter_left and is_boss_shooting == true:
		var new_enemy_bullet = ENEMY_BULLET.instantiate()
		# Set the bullet's position and rotation to match the shooter
		new_enemy_bullet.global_position = shooter_left.global_position
		#new_enemy_bullet.global_rotation = shooter_left.global_rotation
		# Add the bullet to the parent of the shooter or to the main scene
		get_tree().current_scene.add_child(new_enemy_bullet)

func _on_cooldown_timer_timeout() -> void:
	if  cycle_timer.time_left <2 : 
		boss_shoot()

func boss_take_damage():
	boss_health -= spaceship.strength
		#print(enemy_health)

func boss_take_damage_back_bullet():
	boss_health -= spaceship.strength - (0.75*spaceship.strength)
	
#check if bullet enters body area of a boss
func _on_area_boss_entered(area: Area2D) -> void:
	if area.is_in_group("bullet"):
		boss_take_damage()
		print(boss_health)
		boss_explosion.position = Vector2(randf_range(-50,50),randf_range(15,50))   #(randf_range(global_position.x-5,global_position.x+5),randf_range(global_position.y-5,global_position.y+5))
		boss_explosion.emitting = true
		boss_death()
	if area.is_in_group("bullet_back"):
		boss_take_damage_back_bullet()
		boss_explosion.position = Vector2(randf_range(-50,50),randf_range(15,50))   #(randf_range(global_position.x-5,global_position.x+5),randf_range(global_position.y-5,global_position.y+5))
		boss_explosion.emitting = true
		boss_death()
		
#check if spaceship enters body area of a boss
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		spaceship.player_take_damage(boss_damage)

#what happens when boss dies
func boss_death():
	if boss_health <= 0:
		if  boss_type == BossType.EASY:
			is_boss_shooting = false
			main.add_score(boss_score)
			get_node("boss_destroyed").emitting = true
			velocity = Vector2 (0,0)
			var tween = get_tree().create_tween()
			#tween.tween_property(self, "position", Vector2(200,768), 1)
			tween.tween_property(self, "scale", Vector2(0.0,0.0), 1.5)
			
			if spaceship.is_shooting_back == false:
				back_gun_chest.visible = true
				back_gun_chest.position = self.global_position + Vector2(0,0)
			await get_tree().create_timer(3).timeout
			queue_free()
		if boss_type == BossType.NORMAL:
			is_boss_shooting = false
			main.add_score(boss_score)
			get_node("boss_destroyed").emitting = true
			velocity = Vector2 (0,0)
			var tween = get_tree().create_tween()
			#tween.tween_property(self, "position", Vector2(200,768), 1)
			tween.tween_property(self, "scale", Vector2(0.0,0.0), 1.5)
			
			if spaceship.is_multi_shooting == false:
				multi_gun_chest_front.visible = true
				multi_gun_chest_front.position = self.global_position + Vector2(0,0)
			await get_tree().create_timer(3).timeout
			queue_free()
			
#shield enabled
func _on_bullet_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		shield_area.visible = true
		await get_tree().create_timer(3).timeout
		shield_area.visible = false

# boss dropping orbs
#func chance_to_hold_orb():
	#var chance_to_hold_health_orb = randi_range(1,1)
	#var chance_to_hold_att_inc_orb = randi_range(1,1)
	#var chance_to_hold_att_speed_orb = randi_range(1,1)
	#var chance_to_hold_range_orb = randi_range(1,1)
	#var chance_to_hold_steer_orb = randi_range(1,1)
	#if boss_type == BossType.NORMAL:
		#chance_to_hold_health_orb = randi_range(1,10)
		#chance_to_hold_att_inc_orb = randi_range(1,15)
		#chance_to_hold_att_speed_orb = randi_range(1,10)
		#chance_to_hold_range_orb = randi_range(1,5)
		#chance_to_hold_steer_orb = randi_range(1,25)
	#elif boss_type == BossType.HARD:
		#chance_to_hold_health_orb = randi_range(1,15)
		#chance_to_hold_att_inc_orb = randi_range(1,10)
		#chance_to_hold_att_speed_orb = randi_range(1,5)
		#chance_to_hold_range_orb = randi_range(1,15)
		#chance_to_hold_steer_orb = randi_range(1,10)
	# Reference the parent node for adding orbs
	#var orbs_container = get_parent().get_node("%Orbs")
	## Check the conditions in the correct order to avoid overlap
	#if chance_to_hold_health_orb == 1:
		## Health Orb
		#const ORB = preload("res://Scenes/orbs.tscn")
		#var orb = ORB.instantiate()
		#orbs_container.add_child(orb)
		#orb.global_position = global_position
	#elif chance_to_hold_att_inc_orb == 1:
		## Attack Increase Orb
		#const ATT_ORB = preload("res://Scenes/orbs_increase_attack.tscn")
		#var att_orb = ATT_ORB.instantiate()
		#orbs_container.add_child(att_orb)
		#att_orb.position = self.position + Vector2(5,0)
	#elif chance_to_hold_att_speed_orb == 1:
		## Attack Speed Orb
		#const SPEED_ORB = preload("res://Scenes/orbs_increase_speed.tscn")
		#var speed_orb = SPEED_ORB.instantiate()
		#orbs_container.add_child(speed_orb)
		#speed_orb.position = self.position + Vector2(10,0)
	#elif chance_to_hold_range_orb == 1:
		## Range Orb
		#const RANGE_ORB = preload("res://Scenes/orbs_increase_range.tscn") 
		#var range_orb = RANGE_ORB.instantiate()
		#orbs_container.add_child(range_orb)
		#range_orb.position = self.position + Vector2(15,0)
	#elif chance_to_hold_steer_orb == 1:
		## Steer Orb
		#const STEER_ORB = preload("res://Scenes/orbs_increase_steer.tscn") 
		#var steer_orb = STEER_ORB.instantiate()
		#orbs_container.add_child(steer_orb)
		#steer_orb.position = self.position + Vector2(20,0)
