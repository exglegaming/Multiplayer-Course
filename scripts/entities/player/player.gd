class_name Player
extends CharacterBody2D


signal died

const FIRE: StringName = "fire"
const BASE_MOVEMENT_SPEED: float = 100.0
const BASE_FIRE_RATE: float = 0.25
const BASE_BULLET_DAMAGE: int = 1

var input_multiplayer_authority: int
var bullet_scene: PackedScene = preload("uid://c7aiae8nm0c3v")
var muzzle_flash_scene: PackedScene = preload("uid://dw382p5mwq3kl")
var is_dying: bool
var is_respawn: bool
var display_name: String

@onready var player_input_synchronizer_component: PlayerInputSynchronizerComponent = $PlayerInputSynchronizerComponent
@onready var weapon_root: Node2D = $Visuals/WeaponRoot
@onready var fire_rate_timer: Timer = $FireRateTimer
@onready var health_component: HealthComponent = $HealthComponent
@onready var visuals: Node2D = $Visuals
@onready var weapon_animation_player: AnimationPlayer = $WeaponAnimationPlayer
@onready var barrel_position: Marker2D = %BarrelPosition
@onready var display_name_label: Label = $DisplayNameLabel
@onready var activation_area_collision_shape: CollisionShape2D = %ActivationAreaCollisionShape
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent


func _ready() -> void:
	player_input_synchronizer_component.set_multiplayer_authority(input_multiplayer_authority)
	activation_area_collision_shape.disabled = !player_input_synchronizer_component.is_multiplayer_authority()

	if multiplayer.multiplayer_peer is OfflineMultiplayerPeer || player_input_synchronizer_component.is_multiplayer_authority():
		display_name_label.visible = false
	else:
		display_name_label.text = display_name

	if is_multiplayer_authority():
		if is_respawn:
			health_component.current_health = 1
		health_component.died.connect(_on_died)
		hurtbox_component.hit_by_hitbox.connect(_on_hit_by_hitbox)


func _process(delta: float) -> void:
	update_aim_position()
	
	var movement_vector: Vector2 = player_input_synchronizer_component.movement_vector
	if is_multiplayer_authority():
		if is_dying:
			global_position = Vector2.RIGHT * 1000
			return

		var target_velocity: Vector2 = movement_vector * get_movement_speed()
		velocity = velocity.lerp(target_velocity, 1 - exp(-25 * delta))
		move_and_slide()

		if player_input_synchronizer_component.is_attack_pressed:
			try_fire()

	if is_equal_approx(movement_vector.length_squared(), 0):
		animation_player.play("RESET")
	else:
		animation_player.play("run")


func get_movement_speed() -> float:
	var movement_upgrade_count := UpgradeManager.get_peer_upgrade_count(
		player_input_synchronizer_component.get_multiplayer_authority(),
		"movement_speed"
	)

	var speed_modifier: float = 1 + (.15 * movement_upgrade_count)

	return BASE_MOVEMENT_SPEED if !movement_upgrade_count else BASE_MOVEMENT_SPEED * speed_modifier


func get_fire_rate() -> float:
	var fire_rate_count := UpgradeManager.get_peer_upgrade_count(
		player_input_synchronizer_component.get_multiplayer_authority(),
		"fire_rate"
	)

	return BASE_FIRE_RATE * (1 - (.1 * fire_rate_count))


func get_bullet_damage() -> int:
	var damage_count := UpgradeManager.get_peer_upgrade_count(
		player_input_synchronizer_component.get_multiplayer_authority(),
		"damage"
	)

	return BASE_BULLET_DAMAGE + damage_count


@rpc("authority", "call_local")
func start_invulnerability() -> void:
	hurtbox_component.disable_collisions = true
	var tween: Tween = create_tween()
	tween.set_loops(10)
	tween.tween_property(visuals, "visible", false, .05)
	tween.tween_property(visuals, "visible", true, .05)

	tween.finished.connect(func () -> void:
		hurtbox_component.disable_collisions = false
	)


func set_display_name(incoming_name: String) -> void:
	display_name = incoming_name


func update_aim_position() -> void:
	var aim_vector: Vector2 = player_input_synchronizer_component.aim_vector
	var aim_position: Vector2 =  weapon_root.global_position + aim_vector
	visuals.scale = Vector2.ONE if aim_vector.x >= 0 else Vector2(-1, 1)
	weapon_root.look_at(aim_position)


func try_fire() -> void:
	if !fire_rate_timer.is_stopped():
		return

	var bullet := bullet_scene.instantiate() as Bullet
	bullet.damage = get_bullet_damage()
	bullet.global_position = barrel_position.global_position
	bullet.source_peer_id = player_input_synchronizer_component.get_multiplayer_authority()
	bullet.start(player_input_synchronizer_component.aim_vector)
	get_parent().add_child(bullet, true)

	fire_rate_timer.wait_time = get_fire_rate()
	fire_rate_timer.start()

	play_fire_effects.rpc()


@rpc("authority", "call_local", "unreliable")
func play_fire_effects() -> void:
	if weapon_animation_player.is_playing():
		weapon_animation_player.stop()
	weapon_animation_player.play(FIRE)

	var muzzle_flash: Node2D = muzzle_flash_scene.instantiate()
	muzzle_flash.global_position = barrel_position.global_position
	muzzle_flash.rotation = barrel_position.global_rotation
	get_parent().add_child(muzzle_flash)

	if player_input_synchronizer_component.is_multiplayer_authority():
		GameCamera.shake(1.0)


func kill() -> void:
	if !is_multiplayer_authority():
		push_error("Cannot call kill on non-server client")
		return

	_kill.rpc()
	await get_tree().create_timer(.5).timeout

	died.emit()
	queue_free()


@rpc("authority", "call_local", "reliable")
func _kill() -> void:
	is_dying = true
	player_input_synchronizer_component.public_visibility = false


func _on_died() -> void:
	kill()


func _on_hit_by_hitbox() -> void:
	start_invulnerability.rpc()
