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


func get_data(key: StringName, default: Variant = null) -> Variant:
	return _dialogue_data.get(key, default)


func get_text() -> Array:
	return get_data("text", [""])


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
