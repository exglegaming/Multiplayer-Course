class_name UpgradeOption
extends Node2D


signal selected(index: int, for_peer_id: int)

var upgrade_index: int
var assign_resource: UpgradeResource
var peer_id_filter: int

@onready var health_component: HealthComponent = $HealthComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent


func _ready() -> void:
    hurtbox_component.peer_id_filter = peer_id_filter
    health_component.died.connect(_on_died)


func set_peer_id_filter(new_peer_id: int) -> void:
    peer_id_filter = new_peer_id
    hurtbox_component.peer_id_filter = peer_id_filter


func set_upgrade_index(index: int) -> void:
    upgrade_index = index


func set_upgrade_resource(upgrade_resource: UpgradeResource) -> void:
    assign_resource = upgrade_resource


@rpc("authority", "call_local", "reliable")
func kill() -> void:
    var upgrade_option_nodes: Array[Node] = get_tree().get_nodes_in_group("upgrade_option")
    
    for upgrade_option in upgrade_option_nodes:
        if upgrade_option.peer_id_filter == peer_id_filter:
            upgrade_option.queue_free()


func _on_died() -> void:
    selected.emit(upgrade_index, peer_id_filter)
    kill.rpc_id(MultiplayerPeer.TARGET_PEER_SERVER)

    if peer_id_filter != MultiplayerPeer.TARGET_PEER_SERVER:
        kill.rpc_id(peer_id_filter)
