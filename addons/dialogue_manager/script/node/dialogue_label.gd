extends RichTextLabel
class_name DialogueLabel
## 用以显示对话行内容的富文本气泡。


signal dialogue_line_showed (line: DialogueLine)

## 气泡弹出方向
enum PopupDirection {
	NONE = 0,   ## 居中弹出
	LEFT = 1,   ## 向左弹出
	RIGHT = 2,  ## 向右弹出
	UP = 3,     ## 向上弹出
	DOWN = 4,   ## 向下弹出
}

const POPUP_OFFSET: Dictionary[int, Dictionary] = {
	PopupDirection.NONE: {
		"pivot_offset": Vector2(0.5, 0.5),
		"position_offset_size": Vector2(-0.5, -0.5),
		"position_offset_plus": Vector2.ZERO,
	},
	PopupDirection.LEFT: {
		"pivot_offset": Vector2(1.0, 0.5),
		"position_offset_size": Vector2(-1.0, -0.5),
		"position_offset_plus": Vector2(-24.0, 0.0),
	},
	PopupDirection.RIGHT: {
		"pivot_offset": Vector2(0.0, 0.5),
		"position_offset_size": Vector2(+0.0, -0.5),
		"position_offset_plus": Vector2(+24.0, 0.0),
	},
	PopupDirection.UP: {
		"pivot_offset": Vector2(0.5, 1.0),
		"position_offset_size": Vector2(-0.5, -1.0),
		"position_offset_plus": Vector2(0.0, -24.0),
	},
	PopupDirection.DOWN: {
		"pivot_offset": Vector2(0.5, 0.0),
		"position_offset_size": Vector2(-0.5, +0.0),
		"position_offset_plus": Vector2(0.0, +24.0),
	},
}

const DIALOGUE_THEME: Theme = preload("res://addons/dialogue_manager/theme/dialogue_theme.tres")

@export var popup_position: Vector2
@export var popup_direction: PopupDirection

var _label_tweener: Tween
var _dialogue_line_tweening: DialogueLine

var _msec_per_char: float = Dialogue.get_setting_value("msec_per_character")


func _init() -> void:
	bbcode_enabled = true
	fit_content = true
	scroll_active = false
	autowrap_mode = TextServer.AUTOWRAP_OFF
	visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING
	clip_contents = false

	scale = Vector2.ZERO
	theme = DIALOGUE_THEME.duplicate()


## 移除字符串中的所有 BBCode 标签
static func strip_bbcode(bbcode_text: String) -> String:
	var bbcode_regex: RegEx = RegEx.new()
	bbcode_regex.compile("\\[\\/?[a-zA-Z0-9_=\\s\\-\\#\\.\\+\\*\\?]+\\]")
	return bbcode_regex.sub(bbcode_text, "", true).replace("\\[", "[").replace("\\]", "]")


func is_tweening() -> bool:
	return _label_tweener != null && _label_tweener.is_running()


func show_line_text(line: DialogueLine) -> void:
	if line == null: return
	if not line.is_type_text(): return

	_dialogue_line_tweening = line

	var line_text_array: Array = line.get_text()
	var temp_text_array: Array = line_text_array.filter(
		func(value: Variant) -> bool: return value is String)
	var text_stream: String = "".join(
		temp_text_array).replace("\\[", "[").replace("\\]", "]")

	visible_ratio = 0.0
	scale = Vector2.ZERO
	parse_bbcode(text_stream)

	_tween_process.call_deferred(line_text_array)
	await dialogue_line_showed


func _tween_process(text_array: Array) -> void:
	_refresh_popup_offset()
	await _tween_scale(1.0, 0.2)

	var showed_chars: int = 0
	for text_part in text_array: match typeof(text_part):
		TYPE_CALLABLE:
			await text_part.call()
		TYPE_INT, TYPE_FLOAT:
			await get_tree().create_timer(text_part).timeout
		TYPE_STRING, TYPE_STRING_NAME:
			showed_chars += strip_bbcode(text_part).length()
			await _tween_characters(showed_chars)

	dialogue_line_showed.emit(_dialogue_line_tweening)
	_dialogue_line_tweening = null


func _refresh_popup_offset() -> void:
	pivot_offset = _get_popup_pivot_offset()
	position = popup_position + _get_popup_position_offset()
	print(pivot_offset)


func _get_popup_pivot_offset() -> Vector2:
	return POPUP_OFFSET[popup_direction].get("pivot_offset") * size


func _get_popup_position_offset() -> Vector2:
	var position_offset_basic: Vector2 = POPUP_OFFSET[popup_direction].get("position_offset_size") * size
	var position_offset_after: Vector2 = POPUP_OFFSET[popup_direction].get("position_offset_plus")
	return position_offset_basic + position_offset_after


func _refresh_tweener() -> Tween:
	if _label_tweener != null:
		_label_tweener.kill()
	_label_tweener = create_tween()
	return _label_tweener


func _tween_scale(times: float, duration: float) -> void:
	_refresh_tweener().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	_label_tweener.tween_property(
		self, ^"scale", Vector2.ONE * times, duration)
	await _label_tweener.finished


func _get_tween_time(chars: int) -> float:
	return chars * _msec_per_char * 0.001


func _tween_characters(chars: int) -> void:
	var chars_diff: int = absi(visible_characters - chars)
	var tween_time: float = _get_tween_time(chars_diff)

	_refresh_tweener().tween_property(
		self, ^"visible_characters", chars, tween_time)
	await _label_tweener.finished
