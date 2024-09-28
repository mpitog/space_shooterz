extends CanvasLayer

@onready var start_game: Button = $StartGame
@onready var high_score_label: Label = $high_score_label


func _ready() -> void:
	if Global.save_data.high_score != 0:
		high_score_label.visible = true
		high_score_label.text = ("High Score: " + str(Global.save_data.high_score))


func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
