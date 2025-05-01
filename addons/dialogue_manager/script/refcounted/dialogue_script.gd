extends RefCounted
class_name DialogueScript


var _dialogue_data: Dictionary[StringName, Variant]
var _dialogue_lines: Array[DialogueLine]
var _dialogue_manager: Dialogue = Dialogue


func _init(data: Dictionary[StringName, Variant] = {}) -> void:
	_dialogue_data = data
	_dialogue_lines.clear()
	_dialogue_process()
	_dialogue_lines.reverse()
	# 当数据量达到一定程度后，应使用pop_back而非pop_front保证运行速度，
	# 所以将数组颠倒过来后进行提取。


func _dialogue_process() -> void:
	pass


func get_data(key: StringName, default: Variant = null) -> Variant:
	return _dialogue_data.get(key, default)


func get_next_line() -> DialogueLine:
	var next_line: DialogueLine = _dialogue_lines.pop_back()
	return next_line


func add_text(text: Variant, auto_advance: bool = false) -> DialogueLine:
	var new_line: DialogueLine = DialogueLine.get_text_line(text, auto_advance)
	_dialogue_lines.append(new_line)
	return new_line


func add_callable(
	callable: Callable,
	arg_array: Variant = [],
	await_call: bool = false,
	auto_advance: bool = true,
	) -> DialogueLine:

	var new_line: DialogueLine = DialogueLine.get_callable_line(
		callable, arg_array, await_call, auto_advance)
	_dialogue_lines.append(new_line)
	return new_line


func add_timer(wait_time: float) -> DialogueLine:
	var callable: Callable = func():
		await _dialogue_manager.get_tree().create_timer(wait_time).timeout
	return add_callable(callable, [], true, true)


func add_script(
	path: String,
	data: Dictionary[StringName, Variant] = {},
	) -> DialogueLine:

	var callable: Callable = _dialogue_manager.load_dialogue_script
	return add_callable(callable, [path, data], false, true)


func close_label(name: StringName = "", auto_advance: bool = true) -> DialogueLine:
	return add_text([""], auto_advance).set_name(name).set_auto_time(0.0)


static func get_new_script(
	path: String,
	data: Dictionary[StringName, Variant] = {},
	) -> DialogueScript:

	if not ResourceLoader.exists(path, "GDScript"): return
	var new_script_resource: GDScript = ResourceLoader.load(path, "GDScript")
	var new_dialogue_script: DialogueScript = new_script_resource.new(data)
	if not new_dialogue_script is DialogueScript: return
	return new_dialogue_script
