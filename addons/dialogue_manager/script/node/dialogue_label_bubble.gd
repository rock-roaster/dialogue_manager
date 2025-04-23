extends DialogueLabel
class_name DialogueLabelBubble


## 气泡弹出方向
enum PopupDirection {
	NONE = 0,   ## 居中弹出
	LEFT = 1,   ## 向左弹出
	RIGHT = 2,  ## 向右弹出
	UP = 3,     ## 向上弹出
	DOWN = 4,   ## 向下弹出
}

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


func _init(
	popup_position: Vector2,
	popup_direction: PopupDirection = PopupDirection.NONE,
	ms_per_char: float = 25.0,
	enable_bbcode: bool = true,
	pause_between_parts: float = 0.0,
	) -> void:

	set_scale(Vector2.ZERO)
	_popup_position = popup_position
	_popup_direction = popup_direction
	super(ms_per_char, enable_bbcode, pause_between_parts)


func show_line_text(line: DialogueLine) -> void:
	set_scale(Vector2.ZERO)
	await super(line)


func _line_process(line: DialogueLine) -> void:
	_refresh_popup_offset()
	_tween_scale(1.0, 0.2)
	super(line)


func _refresh_popup_offset() -> void:
	_match_popup_bubble()
	pivot_offset = _get_popup_pivot_offset()
	position = _popup_position + _get_popup_position_offset()


func _match_popup_bubble() -> void:
	var target_stylebox: StyleBoxDialogVoice = DIALOGUE_BUBBLE_VOICE.duplicate()\
		if _popup_direction == PopupDirection.NONE else DIALOGUE_BUBBLE_SPEAK.duplicate()
	match _popup_direction:
		PopupDirection.LEFT:
			target_stylebox.arrow_side = StyleBoxDialogSpeak.ArrowSide.RIGHT
		PopupDirection.RIGHT:
			target_stylebox.arrow_side = StyleBoxDialogSpeak.ArrowSide.LEFT
		PopupDirection.UP:
			target_stylebox.arrow_side = StyleBoxDialogSpeak.ArrowSide.DOWN
		PopupDirection.DOWN:
			target_stylebox.arrow_side = StyleBoxDialogSpeak.ArrowSide.UP
	add_theme_stylebox_override(&"normal", target_stylebox)


func _get_popup_pivot_offset() -> Vector2:
	return POPUP_OFFSET[_popup_direction].get("pivot_offset") * size


func _get_popup_position_offset() -> Vector2:
	var position_offset_size: Vector2 = POPUP_OFFSET[_popup_direction].get("position_offset_size") * size
	var position_offset_plus: Vector2 = POPUP_OFFSET[_popup_direction].get("position_offset_plus")
	return position_offset_size + position_offset_plus


func _tween_scale(times: float, duration: float) -> void:
	var tween_scale: Tween = create_tween()
	tween_scale.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween_scale.tween_property(self, ^"scale", Vector2.ONE * times, duration)
	await tween_scale.finished
