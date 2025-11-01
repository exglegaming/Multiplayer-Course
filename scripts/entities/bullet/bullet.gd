class_name Bullet
extends Node2D

const SPEED: int = 600

var direction: Vector2

@onready var life_timer: Timer = $LifeTimer
@onready var hitbox_component: HitboxComponent = $HitboxComponent


func _ready() -> void:
	hitbox_component.hit_hurtbox.connect(_on_hit_hurtbox)
	life_timer.timeout.connect(_on_life_timer_timeout)


func _process(delta: float) -> void:
	global_position += direction * SPEED * delta


func start(dir: Vector2) -> void:
	direction = dir
	rotation = dir.angle()


func register_collision() -> void:
	queue_free()


func _on_life_timer_timeout() -> void:
	if is_multiplayer_authority():
		queue_free()


func _on_hit_hurtbox(_hurtbox_component: HurtboxComponent) -> void:
	register_collision()
