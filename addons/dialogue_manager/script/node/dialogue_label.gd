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

const DIALOGUE_THEME: Theme = preload("res://addons/dialogue_manager/theme/dialogue_theme.tres")
const DIALOGUE_BUBBLE_VOICE: StyleBoxDialogVoice = preload("res://addons/dialogue_manager/theme/stylebox/stylebox_dialog_voice.tres")
const DIALOGUE_BUBBLE_SPEAK: StyleBoxDialogSpeak = preload("res://addons/dialogue_manager/theme/stylebox/stylebox_dialog_speak.tres")

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

var _popup_position: Vector2
var _popup_direction: PopupDirection
var _gaps_between_parts: float

var _label_tweener: Tween
var _target_characters: int
var _dialogue_line_tweening: DialogueLine

var _ms_per_char: float = Dialogue.get_setting_value("msec_per_character")


func _init(
	popup_position: Vector2,
	popup_direction: PopupDirection = PopupDirection.NONE,
	enable_bbcode: bool = true,
	gaps_between_parts: float = 0.0,
	) -> void:

	bbcode_enabled = enable_bbcode
	fit_content = true
	scroll_active = false
	autowrap_mode = TextServer.AUTOWRAP_OFF
	visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING

	clip_contents = false
	scale = Vector2.ZERO
	theme = DIALOGUE_THEME.duplicate()

	_popup_position = popup_position
	_popup_direction = popup_direction
	_gaps_between_parts = gaps_between_parts


## 移除字符串中的所有 BBCode 标签
func strip_bbcode(bbcode_text: String) -> String:
	if not bbcode_enabled: return bbcode_text
	var bbcode_regex: RegEx = RegEx.new()
	bbcode_regex.compile("\\[.*?\\]")
	return bbcode_regex.sub(bbcode_text, "", true)

	#bbcode_regex.compile("\\[\\/?[a-zA-Z0-9_=\\s\\-\\#\\.\\+\\*\\?]+\\]")
	#return bbcode_regex.sub(bbcode_text, "", true).replace("\\[", "[").replace("\\]", "]")


func is_tweening() -> bool:
	return _label_tweener != null && _label_tweener.is_running()


func skip_tween_part() -> void:
	if not is_tweening(): return
	_label_tweener.kill()
	visible_characters = _target_characters
	_label_tweener.finished.emit()


func show_line_text(line: DialogueLine) -> void:
	_dialogue_line_tweening = line

	var line_text_array: Array = line.get_text()
	var temp_text_array: Array = line_text_array.filter(
		func(value: Variant) -> bool: return value is String)
	var text_stream: String = "".join(temp_text_array)

	visible_ratio = 0.0
	scale = Vector2.ZERO
	set_text(text_stream)

	_tween_process.call_deferred(line_text_array)
	await dialogue_line_showed


func _tween_process(text_array: Array) -> void:
	_refresh_popup_offset()
	await _tween_scale(1.0, 0.2)

	_target_characters = 0
	for text_part in text_array:
		match typeof(text_part):
			TYPE_CALLABLE:
				await text_part.call()
			TYPE_INT, TYPE_FLOAT:
				await get_tree().create_timer(text_part).timeout
			TYPE_STRING, TYPE_STRING_NAME:
				_target_characters += strip_bbcode(text_part).length()
				await _tween_characters(_target_characters)
		await get_tree().create_timer(_gaps_between_parts).timeout

	dialogue_line_showed.emit(_dialogue_line_tweening)
	_dialogue_line_tweening = null


func _match_popup_bubble() -> void:
	var target_stylebox: StyleBoxDialogVoice = DIALOGUE_BUBBLE_VOICE.duplicate() if\
		(_popup_direction == PopupDirection.NONE) else DIALOGUE_BUBBLE_SPEAK.duplicate()
	match _popup_direction:
		PopupDirection.LEFT:
			target_stylebox.arrow_side = StyleBoxDialogSpeak.ArrowSide.RIGHT
		PopupDirection.RIGHT:
			target_stylebox.arrow_side = StyleBoxDialogSpeak.ArrowSide.LEFT
		PopupDirection.UP:
			target_stylebox.arrow_side = StyleBoxDialogSpeak.ArrowSide.DOWN
		PopupDirection.DOWN:
			target_stylebox.arrow_side = StyleBoxDialogSpeak.ArrowSide.UP
	add_theme_stylebox_override("normal", target_stylebox)


func _refresh_popup_offset() -> void:
	_match_popup_bubble()
	pivot_offset = _get_popup_pivot_offset()
	position = _popup_position + _get_popup_position_offset()


func _get_popup_pivot_offset() -> Vector2:
	return POPUP_OFFSET[_popup_direction].get("pivot_offset") * size


func _get_popup_position_offset() -> Vector2:
	var position_offset_basic: Vector2 = POPUP_OFFSET[_popup_direction].get("position_offset_size") * size
	var position_offset_after: Vector2 = POPUP_OFFSET[_popup_direction].get("position_offset_plus")
	return position_offset_basic + position_offset_after


func _tween_scale(times: float, duration: float) -> void:
	var tween_scale: Tween = create_tween()
	tween_scale.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween_scale.tween_property(self, ^"scale", Vector2.ONE * times, duration)
	await tween_scale.finished


func _refresh_tweener() -> Tween:
	if _label_tweener != null:
		_label_tweener.kill()
	_label_tweener = create_tween()
	return _label_tweener


func _get_tween_time(chars: int) -> float:
	return chars * _ms_per_char * 0.001


func _tween_characters(chars: int) -> void:
	var chars_diff: int = absi(visible_characters - chars)
	var tween_time: float = _get_tween_time(chars_diff)
	_refresh_tweener().tween_property(self, ^"visible_characters", chars, tween_time)
	await _label_tweener.finished
