extends Node


@export var enemy_manager: EnemyManager
@export var spawn_position: Node2D
@export var spawn_root: Node
@export var available_upgrades: Array[UpgradeResource]

var upgrade_option_scene: PackedScene = preload("uid://c5crefykwsii7")


func _ready() -> void:
	enemy_manager.round_completed.connect(_on_round_completed)


func generate_upgrade_options() -> void:
	var connected_peer_ids: PackedInt32Array = multiplayer.get_peers()
	connected_peer_ids.append(MultiplayerPeer.TARGET_PEER_SERVER)
	for connected_peer_id in connected_peer_ids:
		var selected_upgrades: Array = [available_upgrades[0].id, available_upgrades[0].id, available_upgrades[0].id]
		set_upgrade_options.rpc_id(connected_peer_id, selected_upgrades)


func show_upgrade_resources(upgrade_resources: Array[UpgradeResource]) -> void:
	var initial_x: int = -64
	var x_difference: int = 64

	for i in range(upgrade_resources.size()):
		var upgrade_option: UpgradeOption = upgrade_option_scene.instantiate()
		upgrade_option.global_position = spawn_position.global_position

		upgrade_option.global_position += Vector2.RIGHT * (initial_x + (x_difference * i))

		spawn_root.add_child(upgrade_option)


@rpc("authority", "call_local", "reliable")
func set_upgrade_options(upgrades_ids: Array) -> void:
	var upgrade_resources: Array[UpgradeResource] = []
	for upgrade_id: String in upgrades_ids:
		var resource_index: int = available_upgrades.find_custom(func (item: UpgradeResource) -> bool:
			return item.id == upgrade_id
		)
		upgrade_resources.append(available_upgrades[resource_index])
	show_upgrade_resources(upgrade_resources)


func _on_round_completed() -> void:
	generate_upgrade_options()
