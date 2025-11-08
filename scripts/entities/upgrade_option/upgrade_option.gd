class_name UpgradeOption
extends Node2D


signal selected(index: int)

var upgrade_index: int
var assign_resource: UpgradeResource

@onready var health_component: HealthComponent = $HealthComponent


func _ready() -> void:
    health_component.died.connect(_on_died)


func set_upgrade_index(index: int) -> void:
    upgrade_index = index


func set_upgrade_resource(upgrade_resource: UpgradeResource) -> void:
    assign_resource = upgrade_resource


func _on_died() -> void:
    selected.emit(upgrade_index)
