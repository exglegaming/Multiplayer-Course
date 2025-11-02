extends Node


const MAIN_MENU_SCENE: String = "res://scenes/ui/main_menu/main_menu.tscn"

var player_scene: PackedScene = preload("uid://bvlv7g7jv37sh")
var dead_peers: Array[int] = []

@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var player_spawn_position: Marker2D = $PayerSpawnPosition
@onready var enemy_manager: EnemyManager = $EnemyManager


func _ready() -> void:
	multiplayer_spawner.spawn_function = func(data: Variant) -> Variant:
		var player := player_scene.instantiate() as Player
		player.name = str(data.peer_id)
		player.input_multiplayer_authority = data.peer_id
		player.global_position = player_spawn_position.global_position

		if is_multiplayer_authority():
			player.died.connect(_on_player_died.bind(data.peer_id))

		return player

	peer_ready.rpc_id(1)
	enemy_manager.round_completed.connect(_on_round_completed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


@rpc("any_peer", "call_local", "reliable")
func peer_ready() -> void:
	var sender_id := multiplayer.get_remote_sender_id()
	multiplayer_spawner.spawn({"peer_id": sender_id})
	enemy_manager.sychronize(sender_id)

	print(multiplayer.get_unique_id())


func respawn_dead_peers() -> void:
	for peer_id in dead_peers:
		multiplayer_spawner.spawn({"peer_id": peer_id})
	dead_peers.clear()


func end_game() -> void:
	multiplayer.multiplayer_peer = null
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)


func check_game_over() -> void:
	var is_game_over: bool = true
	var all_peers: PackedInt32Array= multiplayer.get_peers()
	all_peers.push_back(multiplayer.get_unique_id())

	for peer_id in all_peers:
		if !dead_peers.has(peer_id):
			is_game_over = false
			break
	
	if is_game_over:
		end_game()


func _on_player_died(peer_id: int) -> void:
	dead_peers.append(peer_id)
	check_game_over()


func _on_round_completed() -> void:
	respawn_dead_peers()


func _on_server_disconnected() -> void:
	end_game()
