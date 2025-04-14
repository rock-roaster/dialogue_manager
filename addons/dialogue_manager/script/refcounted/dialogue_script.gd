extends RefCounted
class_name DialogueScript


var _dialogue_data: Dictionary[StringName, Variant]
var _dialogue_lines: Array[DialogueLine]


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
	var new_line: DialogueLine = DialogueLine.new(0)
	if text is String: text = [text] as Array
	new_line.set_data("text", text)
	new_line.set_data("auto_advance", auto_advance)
	_dialogue_lines.append(new_line)
	return new_line


func add_callable(
		callable: Callable,
		await_call: bool = false,
		auto_advance: bool = true,
		) -> DialogueLine:
	var new_line: DialogueLine = DialogueLine.new(1)
	new_line.set_data("callable", callable)
	new_line.set_data("await", await_call)
	new_line.set_data("auto_advance", auto_advance)
	_dialogue_lines.append(new_line)
	return new_line


func add_timer(wait_time: float) -> DialogueLine:
	var callable: Callable = func():
		await Dialogue.get_tree().create_timer(wait_time).timeout
	return add_callable(callable, true, true)


func add_script(
		path: String,
		data: Dictionary[StringName, Variant] = {},
		) -> DialogueLine:
	var callable: Callable = Dialogue.load_dialogue_script.bind(path, data)
	return add_callable(callable, false, true)
