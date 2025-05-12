extends Control
class_name Character


const EXPRESSION_JSON_PATH: String = "res://addons/dialogue_manager/script/character/character_expression.json"
const SPEAK_AUDIO_STREAM: AudioStream = preload("res://addons/dialogue_manager/script/character/speaking.wav")

@export var character_data: CharacterData
@export var can_blink: bool = true

@export_group("Default Status")
@export var expression: String = "普通"
@export_range(0.0, 1.0, 0.1) var body_alpha: float = 1.0
@export_range(0.0, 1.0, 0.1) var brightness: float = 1.0

#region inner props
var _default_position: Vector2

var _blink_twice: bool
var _speak_time: float
var _is_speaking: bool

var _texture_eyes: Texture2D
var _texture_mouth: Texture2D

var _speaking_dialogue_label: DialogueLabel

var _thread_speaking: SingleThread = SingleThread.new(true)
var _thread_expression: SingleThread = SingleThread.new(true)

var _expression_dict: Dictionary

var _timer_blink: Timer
var _timer_speak: Timer
var _audio_player: AudioStreamPlayer

var _texture_container: MarginContainer
var _texture_rect_dict: Dictionary[StringName, TextureRect] = {
	"body": null, "face": null, "mouth": null, "eyes": null, "brows": null, "addons": null}
#endregion


func _init(
	_character_data: CharacterData = character_data,
	_expression: String = expression,
	_body_alpha: float = body_alpha,
	_brightness: float = brightness,
	) -> void:

	_blink_twice = false
	_speak_time = 0.1
	_is_speaking = false
	_expression_dict = load_json(EXPRESSION_JSON_PATH)

	character_data = _character_data
	expression = _expression
	body_alpha = _body_alpha
	brightness = _brightness

	_build_node_structure()


func _build_node_structure() -> void:
	var sample_timer: Timer = Timer.new()
	sample_timer.one_shot = true
	_timer_blink = sample_timer.duplicate()
	_timer_speak = sample_timer.duplicate()
	add_child(_timer_blink)
	add_child(_timer_speak)
	sample_timer.queue_free()

	_audio_player = AudioStreamPlayer.new()
	_audio_player.stream = SPEAK_AUDIO_STREAM
	add_child(_audio_player)

	_texture_container = MarginContainer.new()
	_texture_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_texture_container.grow_vertical = Control.GROW_DIRECTION_END
	_texture_container.grow_horizontal = Control.GROW_DIRECTION_BOTH
	add_child(_texture_container)

	var sample_texture_rect: TextureRect = TextureRect.new()
	sample_texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sample_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	for key_name in _texture_rect_dict:
		var texture_duplicate: TextureRect = sample_texture_rect.duplicate()
		_texture_rect_dict[key_name] = texture_duplicate
		_texture_container.add_child(texture_duplicate)
	sample_texture_rect.queue_free()


func load_json(path: String) -> Dictionary:
	var json_file: FileAccess = FileAccess.open(path, FileAccess.READ)
	var json_text: String = json_file.get_as_text()
	return JSON.parse_string(json_text) as Dictionary


func _ready() -> void:
	set_default_position(position)
	_timer_blink.timeout.connect(on_timer_blink_timeout)
	_texture_container.modulate.a = body_alpha
	_texture_container.modulate.v = brightness
	set_character_data(character_data)


func set_character_data(char_data: CharacterData) -> void:
	if char_data == null: return
	character_data = char_data
	_audio_player.set_pitch_scale(char_data.voice_pitch)
	_texture_rect_dict["body"].set_texture(char_data.body_texture)
	change_expression(expression)


func set_character_data_path(path: String) -> void:
	var char_data: CharacterData = CharacterData.get_character_data(path)
	set_character_data(char_data)


func set_default_position(value: Vector2) -> void:
	_default_position = value


func set_speaking_label(label: DialogueLabel) -> void:
	if _speaking_dialogue_label != null:
		_speaking_dialogue_label.character_process_started.disconnect(start_speaking)
		_speaking_dialogue_label.character_process_finished.disconnect(stop_speaking)

	_speaking_dialogue_label = label
	_speaking_dialogue_label.character_process_started.connect(start_speaking.bind(label._ms_per_char * 0.004))
	_speaking_dialogue_label.character_process_finished.connect(stop_speaking)


func start_blink_timer() -> void:
	if _texture_eyes in character_data.eyes_close: return
	var blink_time: float = randf_range(3.0, 6.0)
	_blink_twice = blink_time > 5.0
	_timer_blink.start(blink_time)


func on_timer_blink_timeout() -> void:
	if !can_blink: return
	if _texture_eyes in character_data.eyes_close: return
	await blink_once()
	if _blink_twice:
		await get_tree().create_timer(0.1).timeout
		await blink_once()
	start_blink_timer()


func blink_once() -> void:
	_texture_rect_dict["eyes"].set_texture(character_data.eyes_blink)
	await get_tree().create_timer(0.1).timeout
	_texture_rect_dict["eyes"].set_texture(_texture_eyes)


func start_speaking(sec_per_speak: float = _speak_time) -> void:
	if _is_speaking: return
	_speak_time = sec_per_speak
	_is_speaking = true
	_thread_speaking.add_task(speaking_loop)


func stop_speaking() -> void:
	_is_speaking = false


func speaking_loop() -> void:
	while _is_speaking:
		await speaking_single(character_data.mouth_connect)
		if !_is_speaking: break
		await speaking_single(character_data.mouth_speaking.pick_random())
		if !_is_speaking: break
		await speaking_single(_texture_mouth)
	_texture_rect_dict["mouth"].set_texture(_texture_mouth)


func speaking_single(texture: Texture2D) -> void:
	_texture_rect_dict["mouth"].set_texture(texture)
	_audio_player.play()
	_timer_speak.start(_speak_time)
	await _timer_speak.timeout


func change_position(value: Vector2, time: float = 0.25) -> void:
	var final_position: Vector2 = _default_position + value
	var tween_position: Tween = create_tween()
	tween_position.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween_position.tween_property(self, ^"position", final_position, time)
	await tween_position.finished


func change_texture_offset(value: Vector2, time: float = 0.25) -> void:
	var final_position: Vector2 = Vector2(_texture_container.size.x * -0.5, 0.0) + value
	var tween_position: Tween = create_tween()
	tween_position.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween_position.tween_property(_texture_container, ^"position", final_position, time)
	await tween_position.finished


func change_body_alpha(value: float, time: float = 0.25) -> void:
	var tween_body_alpha: Tween = create_tween()
	tween_body_alpha.tween_property(_texture_container, ^"modulate:a", value, time)
	await tween_body_alpha.finished


func change_brightness(value: float, time: float = 0.25) -> void:
	var tween_brightness: Tween = create_tween()
	tween_brightness.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween_brightness.tween_property(_texture_container, ^"modulate:v", value, time)
	await tween_brightness.finished


func change_expression(exp_name: String = "普通") -> void:
	if !_expression_dict.has(exp_name): return
	expression = exp_name
	_thread_expression.add_task(change_expression_thread.bind(exp_name))


func change_expression_thread(exp_name: String) -> void:
	var string_array: Array = _expression_dict[exp_name]
	change_brows(string_array[0] as String)
	change_eyes(string_array[1] as String)
	change_mouth(string_array[2] as String)


func change_brows(file_name: String) -> void:
	var file_path: String = "%s/眉毛/%s.%s" % [
		character_data.character_dir, file_name, character_data.file_extension]
	var texture2d: Texture2D = ResourceLoader.load(file_path, "Texture2D")
	_texture_rect_dict["brows"].set_texture(texture2d)


func change_eyes(file_name: String) -> void:
	var file_path: String = "%s/眼睛/%s.%s" % [
		character_data.character_dir, file_name, character_data.file_extension]
	var texture2d: Texture2D = ResourceLoader.load(file_path, "Texture2D")
	_texture_eyes = texture2d
	_texture_rect_dict["eyes"].set_texture(_texture_eyes)
	if _timer_blink.is_stopped(): start_blink_timer()


func change_mouth(file_name: String) -> void:
	var file_path: String = "%s/嘴巴/%s.%s" % [
		character_data.character_dir, file_name, character_data.file_extension]
	var texture2d: Texture2D = ResourceLoader.load(file_path, "Texture2D")
	_texture_mouth = texture2d
	_texture_rect_dict["mouth"].set_texture(_texture_mouth)


func change_face(file_name: String = "") -> void:
	var file_path: String = "%s/其他/%s.%s" % [
		character_data.character_dir, file_name, character_data.file_extension]
	var texture2d: Texture2D = ResourceLoader.load(file_path, "Texture2D")
	if !texture2d: texture2d = Texture2D.new()
	_texture_rect_dict["face"].set_texture(texture2d)


func change_addons(file_name: String = "") -> void:
	var file_path: String = "%s/其他/%s.%s" % [
		character_data.character_dir, file_name, character_data.file_extension]
	var texture2d: Texture2D = ResourceLoader.load(file_path, "Texture2D")
	if !texture2d: texture2d = Texture2D.new()
	_texture_rect_dict["addons"].set_texture(texture2d)
