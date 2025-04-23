extends RichTextLabel
class_name DialogueLabel
## 用以显示对话行内容的富文本气泡。


signal dialogue_line_showed (line: DialogueLine)

const DIALOGUE_THEME: Theme = preload("res://addons/dialogue_manager/theme/dialogue_theme.tres")

var _target_characters: int

var _ms_per_char: float
var _pause_between_parts: float

var _characters_tweener: Tween
var _dialogue_line_tweening: DialogueLine


func _init(
	ms_per_char: float = 25.0,
	enable_bbcode: bool = true,
	pause_between_parts: float = 0.0,
	) -> void:

	_setup_richtext_label()
	theme = DIALOGUE_THEME.duplicate()
	bbcode_enabled = enable_bbcode

	_ms_per_char = clampf(ms_per_char, 0.0, ms_per_char)
	_pause_between_parts = clampf(pause_between_parts, 0.0, pause_between_parts)


func _setup_richtext_label() -> void:
	clip_contents = false
	fit_content = true
	scroll_active = false
	autowrap_mode = TextServer.AUTOWRAP_OFF
	visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING


## 移除字符串中的所有 BBCode 标签
func strip_bbcode(bbcode_text: String) -> String:
	if not bbcode_enabled: return bbcode_text
	var bbcode_regex: RegEx = RegEx.new()
	bbcode_regex.compile("\\[.*?\\]")
	return bbcode_regex.sub(bbcode_text, "", true)

	#bbcode_regex.compile("\\[\\/?[a-zA-Z0-9_=\\s\\-\\#\\.\\+\\*\\?]+\\]")
	#return bbcode_regex.sub(bbcode_text, "", true).replace("\\[", "[").replace("\\]", "]")


func is_tweening() -> bool:
	return _characters_tweener != null && _characters_tweener.is_running()


func skip_tween_part() -> void:
	if not is_tweening(): return
	_characters_tweener.kill()
	visible_characters = _target_characters
	_characters_tweener.finished.emit()


func show_line_text(line: DialogueLine) -> void:
	visible_ratio = 0.0

	var line_text_stream: String = line.get_text_stream()
	set_text(line_text_stream)

	_line_process.call_deferred(line)
	await dialogue_line_showed


func _line_process(line: DialogueLine) -> void:
	_dialogue_line_tweening = line
	_target_characters = 0

	var text_array: Array = line.get_text()
	var array_size: int = text_array.size()
	var part_index: int = 0

	for text_part in text_array:
		part_index += 1
		match typeof(text_part):
			TYPE_CALLABLE:
				await text_part.call()
			TYPE_INT, TYPE_FLOAT:
				await get_tree().create_timer(text_part).timeout
			TYPE_STRING, TYPE_STRING_NAME:
				_target_characters += strip_bbcode(text_part).length()
				await _tween_characters(_target_characters)

		if part_index == array_size: break
		await get_tree().create_timer(_pause_between_parts).timeout

	dialogue_line_showed.emit(_dialogue_line_tweening)
	_dialogue_line_tweening = null


func _tween_characters(chars: int) -> void:
	var chars_diff: int = absi(visible_characters - chars)
	var tween_time: float = _get_tween_time(chars_diff)
	_refresh_tweener().tween_property(self, ^"visible_characters", chars, tween_time)
	await _characters_tweener.finished


func _get_tween_time(chars: int) -> float:
	return chars * _ms_per_char * 0.001


func _refresh_tweener() -> Tween:
	if _characters_tweener != null:
		_characters_tweener.kill()
	_characters_tweener = create_tween()
	return _characters_tweener
