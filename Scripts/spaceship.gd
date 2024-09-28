extends CharacterBody2D

const GAME_OVER = preload("res://Scenes/game_over.tscn")
var orb = preload("res://Scenes/orbs.tscn")

var speed : float = 200.0
var sp_range : float = 600.0
var attack_speed  : float = 500.0
var speed_smoother : float = 5.0 #the lower it goes the more "spacey" effect you get

var max_health : int = 15
var health : int = 15
var strength : int = 1 #dmg value for each bullet
var kill_count : int = 0
var bulletcount : int = 0

var is_shooting : bool = true
var is_shooting_back : bool = false
var is_multi_shooting : bool = false
var sound = 1

@onready var engine_effects: AnimatedSprite2D = $Engine/engine_effects
@onready var sprite_spaceship: Sprite2D = $"Body/MainShip-Base-FullHealth"
@onready var health_prog_bar: ProgressBar = $health_prog_bar
@onready var label_timer: Timer = $"../label_timer"

func _ready() -> void:
	pass
	#set_health_bar()

func _process(_delta: float) -> void:
	movement()
	#update_health_bar()

#leave these funcs as comments in case I want to display health under the spaceship
#func set_health_bar() -> void:
	#health_prog_bar.min_value = 0
#	health_prog_bar.max_value = max_health
	#health_prog_bar.value = health
	
#func update_health_bar() ->void:
	#health_prog_bar.value = health

#basic movement
func movement() -> void:
	var input = Input.get_vector("left", "right", "up", "down")
	if input:
		velocity = input.normalized() * speed
		if velocity.y <= 0:
			engine_effects.play("speeding")
		else:
			engine_effects.play("idle")
		if velocity.x > 0:
			self.rotation_degrees = move_toward(0,20,20)
		elif velocity.x < 0:
			self.rotation_degrees = move_toward(0,-20,20)
	else:
		velocity.x = move_toward(velocity.x, 0, speed_smoother)
		velocity.y = move_toward(velocity.y, 0, speed_smoother)
		self.rotation_degrees = 0
	move_and_slide()


#shooting feature
func shoot():
	const BULLET = preload("res://Scenes/bullet.tscn")
	var new_bullet = BULLET.instantiate()
	# Set the bullet's position and rotation to match the shooter
	new_bullet.global_position = global_position
	new_bullet.global_rotation = global_rotation
	# Add the bullet to the parent of the shooter or to the main scene
	get_tree().current_scene.add_child(new_bullet)

	var bullet_sound: AudioStreamPlayer2D = $bullet_sound
	var bullet_sound_2: AudioStreamPlayer2D = $bullet_sound2
	if sound == 1:
		bullet_sound.play()
		sound = 2
	elif sound == 2:
		bullet_sound_2.play()
		sound = 1
	bulletcount += 1
	
	if is_multi_shooting == true :
		const BULLET2 = preload("res://Scenes/bullet.tscn")
		var new_bullet2 = BULLET2.instantiate()
		# Set the bullet's position and rotation to match the shooter
		new_bullet2.global_position = global_position
		new_bullet2.global_rotation = global_rotation - deg_to_rad(10)
		# Add the bullet to the parent of the shooter or to the main scene
		get_tree().current_scene.add_child(new_bullet2)
		
		const BULLET3 = preload("res://Scenes/bullet.tscn")
		var new_bullet3 = BULLET3.instantiate()
		# Set the bullet's position and rotation to match the shooter
		new_bullet3.global_position = global_position
		new_bullet3.global_rotation = global_rotation + deg_to_rad(10)
		# Add the bullet to the parent of the shooter or to the main scene
		get_tree().current_scene.add_child(new_bullet3)

		
func shoot_back():
	if is_shooting_back == true:
		const BULLET = preload("res://Scenes/bullet_back.tscn")
		var new_bullet_back = BULLET.instantiate()
		# Set the bullet's position and rotation to match the shooter
		new_bullet_back.global_position = global_position
		new_bullet_back.global_rotation = global_rotation
		# Add the bullet to the parent of the shooter or to the main scene
		get_tree().current_scene.add_child(new_bullet_back)
		bulletcount += 1
	

func _on_shooting_timer_timeout() -> void:
	if is_shooting:
		shoot()


func _on_shooting_timer_back_timeout() -> void:
	if is_shooting:
		shoot_back()
		
		
#damage and changing sprites according to health
func player_take_damage(enemy_damage):
	health -= enemy_damage
	var damage_particles = get_node("Damage_particles")
	damage_particles.emitting = true
	if health < (max_health-(max_health*0.2)) and health >2:
		var new_texture_injured = load("res://Sprites/Spaceship/Main Ship - Base - Slight damage.png")
		sprite_spaceship.texture = new_texture_injured
	elif health <= 2:
		var new_texture_very_injured = load("res://Sprites/Spaceship/Main Ship - Base - Very damaged.png")
		sprite_spaceship.texture = new_texture_very_injured
	if health <= 0:
		is_shooting = false
		var game_over = get_parent().get_node("Game_over")
		get_tree().paused = true
		game_over.game_over()

#funky spaceship entry
func tween_spaceship_entry():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(200,768), 1)
	tween.tween_property(self, "scale", Vector2(1.5,1.5), 0.5)
	
#### ORBS ####
#add health from health orbs
func add_health(health_to_add):
	if health < max_health:
		health += health_to_add
		show_message($"../GUI/notifications_multi_use", "Health +1")

#increase attack strength from orbs
func increase_attack_strength(orb_att_value) -> void:
	strength  += orb_att_value  
	print('bullet dmg ', strength)
	show_message($"../GUI/notifications_multi_use", "Attack Power Increased")

#increase attack speed from orbs
func increase_attack_speed(orb_att_speed_value) -> void:
	attack_speed  += orb_att_speed_value  
	print('bullet spd ', attack_speed)
	show_message($"../GUI/notifications_multi_use", "Attack Speed Increased")

#increase attack range from orbs
func increase_sp_range(orb_sp_range_value) -> void:
	sp_range += orb_sp_range_value  
	print('range is ', sp_range)
	show_message($"../GUI/notifications_multi_use", "Attack Range Increased")

#improve steering from orbs
func increase_steering(orb_steer_value) -> void:
	speed_smoother += orb_steer_value 
	print('steer ', speed_smoother)
	show_message($"../GUI/notifications_multi_use", "Steering Increased")

#### // ORBS // ####

#singleton for showing pop up messages
func show_message(label: Label, text: String) -> void:
	label.text = text
	label.modulate = Color(0.5, 1, 1, 1)  # Reset opacity to fully visible
	label.visible = true
	label_timer.start()
	#label_timer.timeout
	var tween = get_tree().create_tween()
	tween.tween_property(label, "modulate:a", 0, 3)  # Fade out over 0.5 seconds


#special chest power up - show new gun
func _on_back_gun_chest_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and is_shooting_back == false:
		is_shooting_back = true
		var back_gun = get_node("BodyParts/BackGun")
		back_gun.visible = true
		get_parent().get_node("BackGunChest").queue_free()
		
#special chest power up - shoot 3 bullets from the front


func _on_multi_gun_chest_front_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and is_multi_shooting == false:
		is_multi_shooting = true
		var multi_bullet_front = get_node("BodyParts/multi_bullets_front")
		multi_bullet_front.visible = true
		get_parent().get_node("MultiGunChestFront").queue_free()
