extends CanvasLayer

func _ready() -> void:
	Global.save_data.save()


func game_over() -> void:
	self.visible = true
	get_tree().paused = false

func _on_retry_game_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/start_scene.tscn")
