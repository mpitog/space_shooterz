extends ParallaxBackground

var speed : float = 100

func _process(delta: float) -> void:
	scroll_offset.y -= speed * delta
