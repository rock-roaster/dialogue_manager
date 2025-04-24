extends RefCounted
class_name DialogueLine


enum DialogueType {
	TEXT = 0,
	CALLABLE = 1,
}

var _dialogue_type: DialogueType
var _dialogue_data: Dictionary[StringName, Variant]


func _init(type: int) -> void:
	_dialogue_type = type
	_dialogue_data = {
		"text": [""],
		"callable": Callable(),
		"await": false,
		"auto_advance": false,
	}


func is_type_text() -> bool:
	return _dialogue_type == DialogueType.TEXT


func is_type_callable() -> bool:
	return _dialogue_type == DialogueType.CALLABLE


func has_data(key: StringName) -> bool:
	return _dialogue_data.has(key)


func get_data(key: StringName, default: Variant = null) -> Variant:
	return _dialogue_data.get(key, default)


func get_text() -> Array:
	return get_data("text", [""])


func get_text_stream() -> String:
	var line_text_array: Array = get_text()
	var temp_text_array: Array = line_text_array.filter(
		func(value: Variant) -> bool: return value is String or value is StringName)
	var text_stream: String = "".join(temp_text_array)
	return text_stream


func get_callable() -> Callable:
	return get_data("callable", Callable())


func set_data(key: StringName, value: Variant) -> DialogueLine:
	_dialogue_data.set(key, value)
	return self


func set_data_dict(
		data: Dictionary[StringName, Variant],
		overwrite: bool = true,
		) -> DialogueLine:
	_dialogue_data.merge(data, overwrite)
	return self


static func get_text_line(text: Variant, auto_advance: bool = false) -> DialogueLine:
	var new_line: DialogueLine = DialogueLine.new(0)
	if text is String or text is StringName: text = [text] as Array
	new_line.set_data("text", text)
	new_line.set_data("auto_advance", auto_advance)
	return new_line


static func get_callable_line(
		callable: Callable,
		await_call: bool = false,
		auto_advance: bool = true,
		) -> DialogueLine:
	var new_line: DialogueLine = DialogueLine.new(1)
	new_line.set_data("callable", callable)
	new_line.set_data("await", await_call)
	new_line.set_data("auto_advance", auto_advance)
	return new_line


#region set_line_data
func set_name(value: StringName) -> DialogueLine:
	return set_data("name", value)

func set_position(value: Vector2) -> DialogueLine:
	return set_data("position", value)

func set_direction(value: int) -> DialogueLine:
	return set_data("direction", value)

func set_ms_per_char(value: float) -> DialogueLine:
	return set_data("ms_per_char", value)

func set_gaps_time(value: float) -> DialogueLine:
	return set_data("gaps_time", value)

func set_auto_time(value: float) -> DialogueLine:
	return set_data("auto_time", value)

func set_bbcode_enabled(value: bool) -> DialogueLine:
	return set_data("bbcode_enabled", value)

func set_popup_label(value: bool) -> DialogueLine:
	return set_data("popup_label", value)

func set_popup_parent(value: Node) -> DialogueLine:
	return set_data("popup_parent", value)
#endregion
