extends CharacterBody2D


var current_health: int = 5
var target_position: Vector2

@onready var area_2d: Area2D = $Area2D
@onready var target_acquisistion_timer: Timer = $TargetAcquisitionTimer


func _ready() -> void:
    area_2d.area_entered.connect(_on_area_entered)
    target_acquisistion_timer.timeout.connect(_on_target_aqcuisition_timer_timeout)
    
    if is_multiplayer_authority():
        acquire_target()


func _process(delta: float) -> void:
    if is_multiplayer_authority():
        velocity = global_position.direction_to(target_position) * 40
        move_and_slide()


func handle_hit() -> void:
    current_health -= 1
    if current_health <= 0:
        queue_free()


func acquire_target() -> void:
    var players := get_tree().get_nodes_in_group("player")
    var nearest_player: Player = null
    var nearest_squared_distance: float

    for player in players:
        if nearest_player == null:
            nearest_player = player
            nearest_squared_distance = nearest_player.global_position.distance_squared_to(global_position)
            continue
        
        var player_sqaured_distance: float = player.global_position.distance_squared_to(global_position)
        if player_sqaured_distance < nearest_squared_distance:
            nearest_squared_distance = player_sqaured_distance
            nearest_player = player
    
    if nearest_player != null:
        target_position = nearest_player.global_position


func _on_area_entered(other_area: Area2D) -> void:
    if !is_multiplayer_authority():
        return

    if other_area.owner is Bullet:
        var bullet := other_area.owner as Bullet
        bullet.RegisterCollision()
        handle_hit()


func _on_target_aqcuisition_timer_timeout() -> void:
    if is_multiplayer_authority():
        acquire_target()
