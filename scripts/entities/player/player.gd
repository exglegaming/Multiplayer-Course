class_name Player
extends CharacterBody2D

var input_multiplayer_authority: int
var bullet_scene: PackedScene = preload("uid://c7aiae8nm0c3v")

@onready var player_input_synchronizer_component: PlayerInputSynchronizerComponent = $PlayerInputSynchronizerComponent
@onready var weapon_root: Node2D = $WeaponRoot
@onready var fire_rate_timer: Timer = $FireRateTimer


func _ready() -> void:
    player_input_synchronizer_component.set_multiplayer_authority(input_multiplayer_authority)


func _process(delta: float) -> void:
    var aim_position: Vector2 =  weapon_root.global_position + player_input_synchronizer_component.aim_vector
    weapon_root.look_at(aim_position)

    if is_multiplayer_authority():
        velocity = player_input_synchronizer_component.movement_vector * 100
        move_and_slide()
        if player_input_synchronizer_component.is_attack_pressed:
            try_create_bullet()


func try_create_bullet() -> void:
    if !fire_rate_timer.is_stopped():
        return
    
    var bullet := bullet_scene.instantiate() as Bullet
    bullet.global_position = weapon_root.global_position
    bullet.start(player_input_synchronizer_component.aim_vector)
    get_parent().add_child(bullet, true)
    fire_rate_timer.start()
