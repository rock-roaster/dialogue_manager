extends Node


signal dialogue_line_pushed(line: DialogueLine)
signal dialogue_line_finished(line: DialogueLine)

signal dialogue_script_started(script: DialogueScript)
signal dialogue_script_finished(script: DialogueScript)

const SETTING_SCRIPT: Script = preload("res://addons/dialogue_manager/setting.gd")

var _dialogue_line_processing: DialogueLine
var _dialogue_script_processing: DialogueScript

var _can_push_dialogue_line: bool

var _dialogue_line_history: Array[DialogueLine]
var _dialogue_line_history_maximum: int = get_setting_value("log_history")


func get_setting_value(key: StringName, default: Variant = null) -> Variant:
	return SETTING_SCRIPT.get_setting_value(key, default)


func _init() -> void:
	_can_push_dialogue_line = false


func load_dialogue_script(
		path: String,
		data: Dictionary[StringName, Variant] = {},
		) -> void:

	var new_script_resource: GDScript = ResourceLoader.load(path, "GDScript")
	var new_dialogue_script: DialogueScript = new_script_resource.new(data)

	if new_dialogue_script is not DialogueScript: return
	_dialogue_script_processing = new_dialogue_script
	_can_push_dialogue_line = true
	dialogue_script_started.emit(new_dialogue_script)


func get_next_line() -> DialogueLine:
	if not _can_push_dialogue_line: return
	if _dialogue_script_processing == null: return

	_can_push_dialogue_line = false
	var next_line: DialogueLine = _dialogue_script_processing.get_next_line()
	_dialogue_line_processing = next_line

	# 当对话脚本运行完毕
	if next_line == null:
		dialogue_script_finished.emit(_dialogue_script_processing)
		_dialogue_script_processing = null
		return

	dialogue_line_pushed.emit(next_line)

	# 将推出的对话行保存至运行对话行
	_dialogue_line_process(next_line)

	return next_line


## 在每个对话行运行完成后调用该函数以允许推进对话，不建议通过input输入手动调用。
func _finish_line() -> void:
	if _can_push_dialogue_line: return
	if _dialogue_line_processing == null: return

	_can_push_dialogue_line = true
	dialogue_line_finished.emit(_dialogue_line_processing)


func _dialogue_line_process(line: DialogueLine) -> void:
	match line._dialogue_type:
		DialogueLine.DialogueType.TEXT:
			_dialogue_line_process_text(line)
		DialogueLine.DialogueType.CALLABLE:
			_dialogue_line_process_callable(line)


func _dialogue_line_process_text(line: DialogueLine) -> void:
	_add_history_line(line)


## 将对话行添加至历史对话行
func _add_history_line(line: DialogueLine) -> void:
	if _dialogue_line_history_maximum <= 0: return
	_dialogue_line_history.append(line)

	# 若历史记录大于最大数量，则削至最大数量。
	if _dialogue_line_history.size() <= _dialogue_line_history_maximum: return
	_dialogue_line_history.reverse()
	_dialogue_line_history.resize(_dialogue_line_history_maximum)
	_dialogue_line_history.reverse()


func _dialogue_line_process_callable(line: DialogueLine) -> void:
	var line_callable: Callable = line.get_callable()
	var line_await: bool = line.get_data("await")
	var line_auto_advance: bool = line.get_data("auto_advance")

	if line_callable.is_valid():
		if line_await:
			await line_callable.call()
		else:
			line_callable.call()

	_finish_line()
	if line_auto_advance: get_next_line()
