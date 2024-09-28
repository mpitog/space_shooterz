extends Node

@onready var h_slider_master: HSlider = get_node("HSlider_master")
var master_index : int

func _ready() -> void:
	master_index = AudioServer.get_bus_index("Master")
	print(master_index)
	var temp_vol = _get_volume(master_index)
	h_slider_master.value = db_to_linear(temp_vol)
	print(h_slider_master.value)

func _get_volume (bus_index : int) -> float:
	var db_volume = AudioServer.get_bus_volume_db(bus_index)
	return db_to_linear(db_volume)

func _set_volume (bus_index : int, volume : float):
	var db_volume = linear_to_db(volume)
	AudioServer.set_bus_volume_db(bus_index, db_volume)

func _on_h_slider_master_value_changed(value: float) -> void:
	_set_volume(master_index,value)
