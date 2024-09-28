extends Resource
class_name SaveData

#need to export the var in order to save it in the resource
@export var high_score:int
#default path in users machine - name doesnt really matter
const SAVE_PATH: String = "user://save_data.tres"

#gd singleton for saving resources
func save() -> void:
	ResourceSaver.save(self, SAVE_PATH)
#check if file exists and load it or create new one
static func load_or_create() -> SaveData:
	var res : SaveData
	if FileAccess.file_exists(SAVE_PATH):
		res = load(SAVE_PATH) as SaveData
	else:
		res = SaveData.new()
	return res
