extends Resource
class_name CharacterData


@export var body_texture: Texture2D
@export var file_suffix: String = "png"
@export_range(0.5, 1.5, 0.01) var voice_pitch: float = 1.0

@export_category("Eyes Texture")
@export var eyes_blink: Texture2D
@export var eyes_close: Array[Texture2D]

@export_category("Mouth Texture")
@export var mouth_connect: Texture2D
@export var mouth_speaking: Array[Texture2D]

var character_dir: String


func _init() -> void:
	character_dir = get_path().get_base_dir()
