extends RichTextLabel
class_name DialogueLabel
## 用以显示对话行内容的富文本气泡。


signal dialogue_line_showed (line: DialogueLine)
signal character_process_started
signal character_process_finished

const DIALOGUE_THEME: Theme = preload("res://addons/dialogue_manager/theme/dialogue_theme.tres")

var _target_characters: int

var _ms_per_char: float
var _pause_between_parts: float

var _pause_timer: LiteTimer
var _characters_timer: LiteTimer

var _dialogue_line_tweening: DialogueLine


func _init(
	ms_per_char: float = 25.0,
	enable_bbcode: bool = true,
	pause_between_parts: float = 0.0,
	) -> void:

	clip_contents = false
	fit_content = true
	scroll_active = false
	autowrap_mode = TextServer.AUTOWRAP_OFF
	visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING
	z_index = 5

	theme = DIALOGUE_THEME.duplicate()
	bbcode_enabled = enable_bbcode

	_ms_per_char = clampf(ms_per_char, 0.0, ms_per_char)
	_pause_between_parts = clampf(pause_between_parts, 0.0, pause_between_parts)

	_pause_timer = LiteTimer.new()
	add_child(_pause_timer)

	_characters_timer = LiteTimer.new()
	add_child(_characters_timer)


## 移除字符串中的所有 BBCode 标签
func strip_bbcode(bbcode_text: String) -> String:
	if not bbcode_enabled: return bbcode_text
	var bbcode_regex: RegEx = RegEx.new()
	bbcode_regex.compile("\\[.*?\\]")
	return bbcode_regex.sub(bbcode_text, "", true)

	#bbcode_regex.compile("\\[\\/?[a-zA-Z0-9_=\\s\\-\\#\\.\\+\\*\\?]+\\]")
	#return bbcode_regex.sub(bbcode_text, "", true).replace("\\[", "[").replace("\\]", "]")


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
				await _pause_timer.count_down(text_part)
			TYPE_STRING, TYPE_STRING_NAME:
				_target_characters += strip_bbcode(text_part).length()
				await _visible_characters_process(_target_characters)

		if part_index == array_size: break
		await _pause_timer.count_down(_pause_between_parts)

	dialogue_line_showed.emit(_dialogue_line_tweening)
	_dialogue_line_tweening = null


func _visible_characters_process(chars: int) -> void:
	if _ms_per_char <= 0.0:
		visible_characters = chars
		return

	character_process_started.emit()
	var sec_per_char: float = _ms_per_char * 0.001
	while visible_characters != chars:
		visible_characters = move_toward(visible_characters, chars, 1.0)
		if visible_characters == chars: break
		await _characters_timer.count_down(sec_per_char)
	character_process_finished.emit()


func line_processing() -> bool:
	return _pause_timer.is_running or _characters_timer.is_running


func break_line_process() -> void:
	if _pause_timer.is_running:
		_pause_timer.break_count_down()

	if _characters_timer.is_running:
		visible_characters = _target_characters
		_characters_timer.break_count_down()
