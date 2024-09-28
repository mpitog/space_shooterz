extends Node2D

@onready var spaceship: CharacterBody2D = $Spaceship
@onready var lower_rect: ColorRect = $Background/ColorRect_background/lower_rect
@onready var game_over: CanvasLayer = $Game_over
@onready var difficulty_inc_timer: Timer = $difficulty_inc_timer
@onready var health_prog_bar: ProgressBar = $GUI/health_prog_bar
@onready var enemy: Base_enemy = $Enemies_mob/Enemy
@onready var strength_label: Label = %Strength
@onready var attack_speed_label: Label = %"Attack Speed"
@onready var range_label: Label = %Range
@onready var steering: Label = %Steering
@onready var fps: Label = %FPS

#@onready var boss: Boss_Phobos = %Boss
#@onready var bgmusic_1: AudioStreamPlayer2D = $Bgmusic_1
#var bgmusic_1_audio_stream = load ("res://Audio/mixkit-mystwrious-bass-pulse-2298.wav")

const BOSS = preload("res://Scenes/boss.tscn")
const ENEMY = preload("res://Scenes/enemy.tscn")
var boss = BOSS.instantiate()

var score : int = 0
var high_score : int 
var playtime : float = 0.0
var is_tracking :bool = false
var diff_level : int = 1

func _ready() -> void:
	spaceship.tween_spaceship_entry()
	reset_playtime()
	start_tracking()
	set_health_bar()
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),1.0)
	#if bgmusic_1_audio_stream is AudioStream:
		#bgmusic_1.loop = true
	#bgmusic_1.stream = bgmusic_1_audio_stream

func _process(delta: float) -> void:
	set_strength_label()
	update_health_bar()
	set_attack_speed_label()
	set_range_label()
	set_steering_label()
	var score_label = get_node("GUI/Score")
	var playtime_label = get_node("%Playtime")
	score_label.text = ("Score: " + str(score))
	playtime_label.text = ("Playtime: " + str(int(playtime)))
	#run the playtime clock
	if is_tracking:
		playtime += delta
		#print(playtime)
	fps.text = ("FPS: " + str(Engine.get_frames_per_second()) )

		
func set_health_bar() -> void:
	health_prog_bar.min_value = 0
	health_prog_bar.max_value = spaceship.max_health
	health_prog_bar.value = spaceship.health
	
func update_health_bar() ->void:
	health_prog_bar.value = spaceship.health

#track playtime
func start_tracking() -> void:
	is_tracking = true
	set_process(true)  # Start the _process function to update the time
	
func stop_tracking() -> void:
	is_tracking = false
	set_process(false)  # Stop the _process function
	
# Reset playtime (optional, e.g., when starting a new game)
func reset_playtime() -> void:
	playtime = 0.0

#func format_playtime() -> String:
	#var minutes = int(playtime) / 60
	#var seconds = int(playtime) % 60
	#return str(minutes) + "m " + str(seconds) + "s"
	#print(minutes, seconds)

func spawn_mob():
	if get_tree().paused == false and game_over.visible == false:
		var new_mob = preload("res://Scenes/enemy.tscn").instantiate()
		%PathFollow2D.progress_ratio = randf()
		new_mob.global_position = %PathFollow2D.global_position
		get_node("Enemies_mob").add_child(new_mob)
	else:
		print ('has stopped spawning')

		
func _on_timer_mob_spawn_timeout() -> void:
	spawn_mob()

func add_score(enemy_score):
	score += enemy_score

#cahnce color of bootom rectangle the sense of taking dmg
func animate_mothership_damage():
	lower_rect.color = Color("ff5f43")
	await get_tree().create_timer(0.1).timeout
	lower_rect.color = Color("00b0c1")
	
func _on_game_over_visibility_changed() -> void:
	get_node("Game_over/score_label_game_over_scene").text = ("Score: " + str(score))
	#remove remaining mobs
	if game_over.visible == true:
		var remaining_enemies_after_game_over = get_node("Enemies_mob").get_child_count()
		#print(remaining_enemies_after_game_over)
		for i in remaining_enemies_after_game_over:
			get_node("Enemies_mob").get_child(i).queue_free()
		#set highscore - access global and save in case new high score is set
		if score >= Global.save_data.high_score:
			Global.save_data.high_score = score
			high_score = Global.save_data.high_score
			Global.save_data.save()
			get_node("Game_over/high_score_label_game_over_scene2").text = ("High Score: " + str(high_score))
			if high_score == score:
				get_node("Game_over/CPUParticles2Dfast").visible = false
				get_node("Game_over/high_score_CPUParticles2Dfast2").visible = true
				get_node("Game_over/highscore_bg").visible = true
				get_node("Game_over/new_high_score").visible = true
		else:
			high_score = Global.save_data.high_score
			Global.save_data.save()
			get_node("Game_over/high_score_label_game_over_scene2").text = ("High Score: " + str(high_score))
		#reset playtime
		if playtime:
			stop_tracking()
			#format_playtime()
			#print("playtime:" , playtime)

###### Diff increasing over time  #####
func _on_difficulty_inc_timer_timeout() -> void:
		var bg1 = get_node("Background/CPUParticles2D")
		var mob_timer = get_node("Timer_mob_spawn")
		if diff_level == 1:
			bg1.gravity.y += 10
			mob_timer.wait_time -= 0.05
			diff_level += 1
			#print("level increased", diff_level)
			spaceship.show_message($GUI/notifications_multi_use, "Difficulty Increased")
		elif diff_level >= 2:
			bg1.gravity.y += 10
			mob_timer.wait_time -= 0.05
			diff_level += 1
#instantiate boss
			var new_boss = preload("res://Scenes/boss.tscn").instantiate()
			print (new_boss.boss_type)
			%PathFollow2D.progress_ratio = randf()
			new_boss.global_position = Vector2 (0,0)
			new_boss.visible = true
			new_boss.is_boss_shooting = true
			get_node('Bosses').add_child(new_boss)
			#print("level increased", diff_level)
			spaceship.show_message($GUI/notifications_multi_use, "Difficulty Increased")



#### Label setter #####

func set_strength_label():
	strength_label.text = ("Power: " + str(spaceship.strength))

func set_attack_speed_label():
	attack_speed_label.text = ("Attack Speed: " + str(spaceship.attack_speed))

func set_range_label():
	range_label.text = ("Range: " + str(spaceship.sp_range))

func set_steering_label():
	steering.text = ("Steering: " + str(spaceship.speed_smoother-4.0))


#lower GUI opacity when player enters area
func _on_gui_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var tween = get_tree().create_tween()
		tween.tween_property(get_node("GUI/Attack Speed"), "modulate:a", 0.2, 0.5) 
		var tween2 = get_tree().create_tween()		
		tween2.tween_property(get_node("GUI/Range"), "modulate:a", 0.2, 0.5) 
		var tween3 = get_tree().create_tween()
		tween3.tween_property(get_node("GUI/Strength"), "modulate:a",0.2, 0.5)
		var tween4 = get_tree().create_tween()
		tween4.tween_property(get_node("GUI/Steering"), "modulate:a", 0.2, 0.5) 
func _on_gui_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		var tween = get_tree().create_tween()
		tween.tween_property(get_node("GUI/Attack Speed"), "modulate:a", 1.0, 1) 
		var tween2 = get_tree().create_tween()		
		tween2.tween_property(get_node("GUI/Range"), "modulate:a", 1.0, 1) 
		var tween3 = get_tree().create_tween()
		tween3.tween_property(get_node("GUI/Strength"), "modulate:a",1.0, 1)
		var tween4 = get_tree().create_tween()
		tween4.tween_property(get_node("GUI/Steering"), "modulate:a", 1.0, 1) 



##### Pause menu#####

func _on_pause_button_pressed() -> void:
	var pause_layer = get_node("Game_paused/ColorRect")
	get_tree().paused = true
	pause_layer.visible = true

func _on_resume_button_pressed() -> void:
	var pause_layer = get_node("Game_paused/ColorRect")
	get_tree().paused = false
	pause_layer.visible = false

func _on_restart_pressed() -> void:
	#var pause_layer = get_node("Game_paused/ColorRect")
	get_tree().paused = false
	#pause_layer.visible = false
	get_tree().change_scene_to_file("res://Scenes/start_scene.tscn")
	
