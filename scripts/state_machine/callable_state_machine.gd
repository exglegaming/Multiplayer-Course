class_name CallableStateMachine


var state_dictionary: Dictionary = {}
var current_state: String


func add_states(
	normal_state_callable: Callable,
	enter_state_callable: Callable,
	leave_state_callable: Callable
) -> void:
	state_dictionary[normal_state_callable.get_method()] = {
		"normal": normal_state_callable,
		"enter": enter_state_callable,
		"leave": leave_state_callable
	}


func set_initial_state(state_callable: Callable) -> void:
	var state_name: StringName = state_callable.get_method()
	if state_dictionary.has(state_name):
		_set_state(state_name)
	else:
		push_warning("No state with name " + state_name)


func update() -> void:
	if current_state != null:
		(state_dictionary[current_state].normal as Callable).call()


func change_state(state_callable: Callable) -> void:
	var state_name: StringName = state_callable.get_method()
	if state_dictionary.has(state_name):
		_set_state.call_deferred(state_name)
	else:
		push_warning("No state with name " + state_name)


func _set_state(state_name: String) -> void:
	if current_state:
		var leave_callable: Callable = state_dictionary[current_state].leave as Callable
		if !leave_callable.is_null():
			leave_callable.call()

	current_state = state_name
	var enter_callable: Callable = state_dictionary[current_state].enter as Callable
	if !enter_callable.is_null():
		enter_callable.call()
