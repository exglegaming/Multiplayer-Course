class_name PlayerInputSynchronizerComponent
extends MultiplayerSynchronizer


const MOVE_LEFT: StringName = "move_left"
const MOVE_RIGHT: StringName = "move_right"
const MOVE_UP: StringName = "move_up"
const MOVE_DOWN: StringName = "move_down"
const ATTACK: StringName = "attack"

@export var aim_root: Node2D

var movement_vector: Vector2 = Vector2.ZERO
var aim_vector: Vector2 = Vector2.RIGHT
var is_attack_pressed: bool


func _process(_delta: float) -> void:
	if is_multiplayer_authority():
		gather_input()


func gather_input() -> void:
	movement_vector = Input.get_vector(MOVE_LEFT, MOVE_RIGHT, MOVE_UP, MOVE_DOWN)
	aim_vector = aim_root.global_position.direction_to(aim_root.get_global_mouse_position())
	is_attack_pressed = Input.is_action_pressed(ATTACK)
