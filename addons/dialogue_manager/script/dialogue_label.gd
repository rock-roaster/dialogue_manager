extends RichTextLabel
class_name DialogueLabel


signal dialogue_line_showed (line: DialogueLine)

@export_range(0.0, 100.0, 0.1) var ms_per_char: float = 40.0
@export var can_break: bool = true

var _text_tweener: Tween
var _text_tweening: bool


func _init() -> void:
	bbcode_enabled = true
	fit_content = true
	scroll_active = false
	autowrap_mode = TextServer.AUTOWRAP_OFF

	_text_tweening = false


func break_tween() -> void:
	if not can_break: return

	if _text_tweener != null:
		_text_tweener.kill()
		_text_tweener.finished.emit()

	visible_ratio = 1.0


func show_line_text(line: DialogueLine) -> void:
	if line == null: return
	if not line.is_type_text(): return

	var dialogue_text: String = line.get_text()
	var dialogue_auto: bool = line.get_data("auto_advance")

	visible_ratio = 0.0
	set_text(dialogue_text)
	await _tween_ratio(1.0)

	if dialogue_auto: await get_tree().create_timer(0.2).timeout
	dialogue_line_showed.emit(line)


func _get_visible_char() -> int:
	return get_parsed_text().c_escape().length()


func _get_tween_time(char: int) -> float:
	var tween_time: float = char * ms_per_char * 0.001
	return tween_time


func _refresh_tweener() -> Tween:
	if _text_tweener != null:
		_text_tweener.kill()
	_text_tweener = create_tween()
	return _text_tweener


func _tween_character(char: int) -> void:
	var tween_char: int = absi(visible_characters - char)
	var tween_time: float = _get_tween_time(tween_char)

	_refresh_tweener()
	_text_tweener.tween_property(self, ^"visible_characters", char, tween_time)

	_text_tweening = true
	await _text_tweener.finished
	_text_tweening = false


func _tween_ratio(ratio: float) -> void:
	var ratio_gaps: float = absf(visible_ratio - ratio)
	var tween_char: float = _get_visible_char() * ratio_gaps
	var tween_time: float = _get_tween_time(tween_char)

	_refresh_tweener()
	_text_tweener.tween_property(self, ^"visible_ratio", ratio, tween_time)

	_text_tweening = true
	await _text_tweener.finished
	_text_tweening = false
