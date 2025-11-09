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


func _on_died() -> void:
    selected.emit(upgrade_index, peer_id_filter)
