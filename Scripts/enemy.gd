extends Area2D
class_name Base_enemy

var enemy_score : int = 1
var enemy_level : int = 1
var enemy_health : int = 1
var enemy_damage : int = 1
enum EnemyType { BASIC, AGGR0, FAT }
var enemy_type
var velocity : Vector2 = Vector2(0,0)
@onready var spaceship: CharacterBody2D = $"../../Spaceship"
@onready var main: Node2D = $"../.."
@onready var lower_bg: Sprite2D = $"../../Background/LowerBg"
@onready var orbs_attack_power: Increase_Attack_Power_Orb = $"../../Orbs/Orbs_attack_power"
@onready var enemy_explosion: CPUParticles2D = $enemy_explosion
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


const BASIC_BULLET = preload("res://Scenes/bullet.tscn")
var basic_bullet = BASIC_BULLET


const BASIC_BULLET_BACK = preload("res://Scenes/bullet_back.tscn")
var basic_bullet_back: BasicBulletBack = BASIC_BULLET_BACK.instantiate()


func _ready() -> void:
	var chance_to_aggro : int = randi_range(1,20)
	var chance_to_fat : int = randi_range(1,30)
	if chance_to_aggro == 1:
		enemy_type = EnemyType.AGGR0
	elif chance_to_fat == 1:
		enemy_type = EnemyType.FAT
	else:
		enemy_type = EnemyType.BASIC
	chance_to_hold_orb()
	aggro_enemy_stats()
	fat_enemy_stats()

#adjust velocity and position according to enum
func _physics_process(delta: float) -> void:
	if enemy_type == EnemyType.BASIC :
		velocity += Vector2(0,50)
		position.y = velocity.y * delta
	elif  enemy_type == EnemyType.AGGR0:
		velocity += Vector2 (10,100)
		var target_pos = spaceship.global_position
		position.x = move_toward(position.x, target_pos.x,0.5)
		position.y = velocity.y * delta 
		get_node("Sprite2D").use_parent_material = false
	elif  enemy_type == EnemyType.FAT :
		velocity += Vector2 (0,30)
		position.y = velocity.y * delta 
		get_node("Sprite2D").use_parent_material = false

#redefine stats according to type
func aggro_enemy_stats():
	if enemy_type == EnemyType.AGGR0:
		enemy_damage = 2
		enemy_health = 5
		enemy_score = 2
		sprite_2d.modulate = Color (0.0,1.0,1.0,1.0)
		enemy_type = EnemyType.AGGR0
func fat_enemy_stats():
	if enemy_type == EnemyType.FAT:
		enemy_damage = 5
		enemy_health = 15
		enemy_score = 5
		collision_shape_2d.scale = 4 * collision_shape_2d.scale
		sprite_2d.scale = 4 * sprite_2d.scale 
		sprite_2d.modulate = Color (1.0,0.0,1.0,1.0)
		enemy_type = EnemyType.FAT

# on impact with player deal dmg and then destory self
func _on_body_entered_player(body: Node2D) -> void:
	if body.is_in_group("player"):
		spaceship.player_take_damage(enemy_damage)
		main.add_score(enemy_score)
		self.queue_free()

func enemy_take_damage():
		enemy_health -= basic_bullet.bullet_damage 
		##print(enemy_health)

#killed by player
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("bullet"):
		enemy_explosion.emitting = true
		enemy_health -= spaceship.strength 
		enemy_death()
	if area.is_in_group("bullet_back"):
		enemy_explosion.emitting = true
		enemy_health -= spaceship.strength * 0.05 # need to check the dmg applied on back bullets
		enemy_death()

func enemy_death():
	if enemy_health <= 0:
		main.add_score(enemy_score)
		chance_to_hold_orb()
		await get_tree().create_timer(0.2).timeout
		queue_free()

# delicate adjustments are needed here --> will alter significantly the gameplay
func chance_to_hold_orb():
	var chance_to_hold_health_orb = randi_range(1,20)
	var chance_to_hold_att_inc_orb = randi_range(1,30)
	var chance_to_hold_att_speed_orb = randi_range(1,20)
	var chance_to_hold_range_orb = randi_range(1,25)
	var chance_to_hold_steer_orb = randi_range(1,50)
	if enemy_type == EnemyType.AGGR0:
		chance_to_hold_health_orb = randi_range(1,10)
		chance_to_hold_att_inc_orb = randi_range(1,15)
		chance_to_hold_att_speed_orb = randi_range(1,10)
		chance_to_hold_range_orb = randi_range(1,5)
		chance_to_hold_steer_orb = randi_range(1,25)
	elif enemy_type == EnemyType.FAT:
		chance_to_hold_health_orb = randi_range(1,15)
		chance_to_hold_att_inc_orb = randi_range(1,10)
		chance_to_hold_att_speed_orb = randi_range(1,5)
		chance_to_hold_range_orb = randi_range(1,15)
		chance_to_hold_steer_orb = randi_range(1,10)
	# Reference the parent node for adding orbs
	var orbs_container = get_parent().get_parent().get_node("Orbs")
	# Check the conditions in the correct order to avoid overlap
	#use call defered to avoid problems with physics engine
	if chance_to_hold_health_orb == 1:
		# Health Orb
		const ORB = preload("res://Scenes/orbs.tscn")
		var orb = ORB.instantiate()
		orbs_container.call_deferred("add_child",orb)
		orb.position = self.position	
	elif chance_to_hold_att_inc_orb == 1:
		# Attack Increase Orb
		const ATT_ORB = preload("res://Scenes/orbs_increase_attack.tscn")
		var att_orb = ATT_ORB.instantiate()
		orbs_container.call_deferred("add_child",att_orb)
		att_orb.position = self.position
	elif chance_to_hold_att_speed_orb == 1:
		# Attack Speed Orb
		const SPEED_ORB = preload("res://Scenes/orbs_increase_speed.tscn")
		var speed_orb = SPEED_ORB.instantiate()
		orbs_container.call_deferred("add_child", speed_orb)
		speed_orb.position = self.position
	elif chance_to_hold_range_orb == 1:
		# Range Orb
		const RANGE_ORB = preload("res://Scenes/orbs_increase_range.tscn") 
		var range_orb = RANGE_ORB.instantiate()
		orbs_container.call_deferred("add_child",range_orb)
		range_orb.position = self.position
	elif chance_to_hold_steer_orb == 1:
		# Steer Orb
		const STEER_ORB = preload("res://Scenes/orbs_increase_steer.tscn") 
		var steer_orb = STEER_ORB.instantiate()
		orbs_container.call_deferred("add_child", steer_orb)
		steer_orb.position = self.position

#qf object when out of bounds
func _process(_delta: float) -> void:
	check_out_of_viewport()
	if lower_bg.use_parent_material == false:
		await get_tree().create_timer(0.1).timeout
		lower_bg.use_parent_material = true
		

func check_out_of_viewport() -> void:
	# Get the viewport's visible rectangle
	var viewport_rect: Rect2 = get_viewport().get_visible_rect()
# Get the global position of the Area2D node
	#var position: Vector2 = global_position
# Check if the Area2D is outside the viewport bounds in any direction
	if global_position.x < viewport_rect.position.x:
		print("Out of viewport on the LEFT side")
	elif global_position.x > viewport_rect.position.x + viewport_rect.size.x:
		print("Out of viewport on the RIGHT side")
	elif global_position.y < viewport_rect.position.y:
		print("Out of viewport on the TOP side")
	elif global_position.y > viewport_rect.position.y + viewport_rect.size.y - 20:
		print("Out of viewport on the BOTTOM side")
		var explosion = get_node("enemy_explosion")
		explosion.emitting = true
		queue_free()
		main.animate_mothership_damage()
		spaceship.player_take_damage(enemy_damage)
		lower_bg.use_parent_material = false
		
		#############
