extends Label

@onready var label_timer: Timer = $"../../label_timer"

# Function to display the message and start the timer
func show_message(text_to_display: String) -> void:
	self.text = text_to_display
	self.modulate = Color(0.5, 1, 1, 1)  # Reset opacity to fully visible
	self.visible = true
	label_timer.start()
	#label_timer.timeout
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0, 2)  # Fade out over 0.5 seconds
