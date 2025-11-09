extends Node


@export var enemy_manager: EnemyManager
@export var spawn_position: Node2D
@export var spawn_root: Node
@export var available_upgrades: Array[UpgradeResource]

var upgrade_option_scene: PackedScene = preload("uid://c5crefykwsii7")
var  peer_id_to_upgrade_opotions: Dictionary[int, Array] = {}


func _ready() -> void:
	enemy_manager.round_completed.connect(_on_round_completed)


func generate_upgrade_options() -> void:
	peer_id_to_upgrade_opotions.clear()

	var connected_peer_ids: PackedInt32Array = multiplayer.get_peers()
	connected_peer_ids.append(MultiplayerPeer.TARGET_PEER_SERVER)
	for connected_peer_id in connected_peer_ids:
		var selected_upgrades: Array = [
			available_upgrades[0].id, 
			available_upgrades[0].id, 
			available_upgrades[0].id
		]

		peer_id_to_upgrade_opotions[connected_peer_id] = [
			available_upgrades[0], 
			available_upgrades[0], 
			available_upgrades[0]
		]
		
		var upgrade_resources: Array[UpgradeResource] = [
			available_upgrades[0], 
			available_upgrades[0], 
			available_upgrades[0]
		]

		var upgrade_options: Array[UpgradeOption] = create_upgrade_option_nodes(upgrade_resources)
		var upgrade_names: Array = []
		for upgrade_option in upgrade_options:
			upgrade_option.set_peer_id_filter(connected_peer_id)
			var uid: int = ResourceUID.create_id()
			upgrade_option.name = str(uid)
			upgrade_names.append(upgrade_option.name)

		if connected_peer_id != MultiplayerPeer.TARGET_PEER_SERVER:
			set_upgrade_options.rpc_id(connected_peer_id, selected_upgrades, upgrade_names)


func create_upgrade_option_nodes(upgrade_resources: Array[UpgradeResource]) -> Array[UpgradeOption]:
	var result: Array[UpgradeOption] = []
	var initial_x: int = -64
	var x_difference: int = 64

	for i in range(upgrade_resources.size()):
		var upgrade_option: UpgradeOption = upgrade_option_scene.instantiate()
		upgrade_option.set_upgrade_index(i)
		upgrade_option.set_upgrade_resource(upgrade_resources[i])

		upgrade_option.global_position = spawn_position.global_position
		upgrade_option.global_position += Vector2.RIGHT * (initial_x + (x_difference * i))

		spawn_root.add_child(upgrade_option)

		upgrade_option.selected.connect(_on_upgrade_option_selected)
		result.append(upgrade_option)

	return result


func handle_upgrade_selected(upgrade_index: int, for_peer_id: int) -> void:
	print("Peer %s has selected upgrade with id %s" % [
		for_peer_id, 
		peer_id_to_upgrade_opotions[for_peer_id][upgrade_index].id
	])


@rpc("authority", "call_local", "reliable")
func set_upgrade_options(upgrades_ids: Array, upgrade_names: Array) -> void:
	var upgrade_resources: Array[UpgradeResource] = []
	for upgrade_id: String in upgrades_ids:
		var resource_index: int = available_upgrades.find_custom(func (item: UpgradeResource) -> bool:
			return item.id == upgrade_id
		)
		upgrade_resources.append(available_upgrades[resource_index])

	var created_nodes: Array[UpgradeOption] = create_upgrade_option_nodes(upgrade_resources)
	for i in created_nodes.size():
		created_nodes[i].name = upgrade_names[i]


func _on_round_completed() -> void:
	generate_upgrade_options()


func _on_upgrade_option_selected(upgrade_index: int, for_peer_id: int) -> void:
	handle_upgrade_selected(upgrade_index, for_peer_id)
