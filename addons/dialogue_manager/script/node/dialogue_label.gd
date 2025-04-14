extends RichTextLabel
class_name DialogueLabel


signal dialogue_line_showed (line: DialogueLine)

const dialogue_theme: Theme = preload("res://addons/dialogue_manager/theme/dialogue_theme.tres")

@export_range(0.0, 100.0, 1.0, "or_greater")
var ms_per_char: float = 25.0

@export_range(0.0, 1.0, 0.01, "or_greater")
var wait_between_parts: float = 0.25

var _text_tweener: Tween
var _text_tweening: bool

var _dialogue_line_tweening: DialogueLine

var _break_tweening: bool = Dialogue.get_setting_value("break_tweening")


func _init() -> void:
	bbcode_enabled = true
	fit_content = true
	scroll_active = false
	autowrap_mode = TextServer.AUTOWRAP_OFF
	visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING
	theme = dialogue_theme.duplicate()

	_text_tweener = null
	_text_tweening = false


static func decode_bb(bb_code: String) -> String:
	var parsed_text: String = bb_code
	while parsed_text.contains("[") && parsed_text.contains("]"):
		var index_l: int = parsed_text.find("[")
		var index_r: int = parsed_text.find("]")
		if not index_l < index_r: break
		var length: int = index_r - index_l + 1
		parsed_text = parsed_text.erase(index_l, length)
	return parsed_text


func show_line_text(line: DialogueLine) -> void:
	if line == null: return
	if not line.is_type_text(): return

	_dialogue_line_tweening = line

	var line_text: Array = line.get_text()
	var dialogue_auto: bool = line.get_data("auto_advance")

	var string_text_array: Array = line_text.filter(
		func(value: Variant) -> bool: return value is String)

	var showed_text: String = "".join(string_text_array)

	visible_ratio = 0.0
	set_text(showed_text)

	var showed_chars: int = 0
	for text_part in line_text:
		if text_part is Callable:
			await text_part.call()

		if text_part is String:
			showed_chars += decode_bb(text_part).length()
			await _tween_characters(showed_chars)
			if showed_chars >= showed_text.length(): break
			await get_tree().create_timer(wait_between_parts).timeout

	if dialogue_auto:
		await get_tree().create_timer(wait_between_parts).timeout

	dialogue_line_showed.emit(_dialogue_line_tweening)
	_dialogue_line_tweening = null


func is_tweening() -> bool:
	return _text_tweening


func break_tween() -> void:
	if not _break_tweening: return
	if _dialogue_line_tweening == null: return

	if _text_tweener != null: _text_tweener.kill()
	visible_ratio = 1.0

	dialogue_line_showed.emit(_dialogue_line_tweening)
	_dialogue_line_tweening = null


func _refresh_tweener() -> Tween:
	if _text_tweener != null:
		_text_tweener.kill()
	_text_tweener = create_tween()
	return _text_tweener


func _get_tween_time(chars: int) -> float:
	return chars * ms_per_char * 0.001


func _tween_characters(chars: int) -> void:
	var chars_diff: int = absi(visible_characters - chars)
	var tween_time: float = _get_tween_time(chars_diff)

	_refresh_tweener().tween_property(
		self, ^"visible_characters", chars, tween_time)

	_text_tweening = true
	await _text_tweener.finished
	_text_tweening = false
