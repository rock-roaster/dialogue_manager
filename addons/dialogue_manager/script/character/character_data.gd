extends Resource
class_name CharacterData


@export_dir var character_dir: String
@export var file_extension: String

@export var body_texture: Texture2D
@export_range(0.5, 1.5, 0.01) var voice_pitch: float = 1.0

@export_category("Eyes Texture")
@export var eyes_blink: Texture2D
@export var eyes_close: Array[Texture2D]

@export_category("Mouth Texture")
@export var mouth_connect: Texture2D
@export var mouth_speaking: Array[Texture2D]


static func get_character_data(file_path: String) -> CharacterData:
	var character_data: CharacterData = ResourceLoader.load(file_path, "Resource") as CharacterData
	character_data.character_dir = character_data.get_path().get_base_dir()
	character_data.file_extension = character_data.body_texture.get_path().get_extension()
	return character_data
