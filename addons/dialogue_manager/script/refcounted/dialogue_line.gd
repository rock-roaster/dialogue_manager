extends RefCounted
class_name DialogueLine


enum DialogueType {
	TEXT,
	CALLABLE,
}

var _dialogue_type: DialogueType
var _dialogue_data: Dictionary[StringName, Variant]


func set_type(type: DialogueType) -> void:
	_dialogue_type = type


func set_data(key: StringName, value: Variant) -> void:
	_dialogue_data.set(key, value)


func _init() -> void:
	_dialogue_data = {
		"text": "",
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


func get_text() -> String:
	return get_data("text", "")


func get_callable() -> Callable:
	return get_data("callable", Callable())
