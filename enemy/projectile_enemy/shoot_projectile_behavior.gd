extends Node2D

static var projectile :PackedScene = preload("res://enemy/projectile_enemy/projectile/projectile.tscn")
#Attack speed (time between shots)
@export var attack_speed : float = 1.0

#How close the enemy must be to start shooting.
@export var attack_range : float = 2.0

#Accuracy
@export_range(0, 90) var attack_spread : float = 0

#Shoot animation length
@export var animation_length : float = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(projectile != null)
	$CooldownTimer.wait_time = attack_speed
	$AttackRange/CollisionShape2D.scale *= attack_range

func _enter_tree() -> void:
	# apparently, taking a timer out of and back into a tree breaks it, since autostart is disabled after entering the tree
	# since enemies are unloaded and reloaded by taking them out of the tree, we need to work around this
	$CooldownTimer.start.call_deferred()

func timeout() -> void:
	for body: Node2D in $"AttackRange".get_overlapping_bodies():
		if body is Player:
			shoot()

func shoot() -> void:
	var proj : Node2D = projectile.instantiate()
	proj.global_position = self.global_position
	proj.global_rotation_degrees = add_spread(self.global_rotation_degrees, attack_spread)
	get_parent().add_sibling(proj)

func add_spread(rot: float, spread: float) -> float:
	var rand_factor :float = randf()*spread *2 - spread
	return rot + rand_factor
