extends Resource
class_name CharacterData


@export_dir var character_dir: String
@export var body_texture: CompressedTexture2D
@export_range(0.5, 1.5, 0.01) var voice_pitch: float = 1.0

@export_category("Eyes Texture")
@export var eyes_blink: CompressedTexture2D
@export var eyes_close: Array[CompressedTexture2D]

@export_category("Mouth Texture")
@export var mouth_connect: CompressedTexture2D
@export var mouth_speaking: Array[CompressedTexture2D]
