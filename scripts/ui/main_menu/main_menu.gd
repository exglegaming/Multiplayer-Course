extends Control


var main_scene: PackedScene = preload("uid://25v5neekcjpn")
var options_menu_scene: PackedScene = preload("uid://dniyftgku31me")

@onready var multiplayer_menu_scene: PackedScene = load("uid://dwdiv1qyk8twh")
@onready var single_player_button: Button = $VBoxContainer/SinglePlayerButton
@onready var multiplayer_button: Button = $VBoxContainer/MultiplayerButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var options_button: Button = $VBoxContainer/OptionsButton


func _ready() -> void:
	single_player_button.pressed.connect(_on_single_player_button_pressed)
	multiplayer_button.pressed.connect(_on_multiplayer_button_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)

	UIAudioManager.register_buttons([
		single_player_button,
		multiplayer_button,
		options_button,
		quit_button
	])


func _on_single_player_button_pressed() -> void:
	get_tree().change_scene_to_packed(main_scene)


func _on_multiplayer_button_pressed() -> void:
	get_tree().change_scene_to_packed(multiplayer_menu_scene)


func _on_options_pressed() -> void:
	var options_menu: Node = options_menu_scene.instantiate()
	add_child(options_menu)
	


func _on_quit_button_pressed() -> void:
	get_tree().quit()
