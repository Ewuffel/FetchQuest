class_name SpawnerEnemy extends Enemy

@export var spawned_enemy : PackedScene
@export var spawn_amount : int
@export var spawn_on_death : bool
@export var spawn_rate : float
@export var spawn_cap : int
@export var spawn_animation_length : float

func _ready() -> void:
	# wait a single frame in case our _ready was called before the player's
	await get_tree().process_frame

func _physics_process(_delta: float) -> void:
	if Player.instance == null: return
	
	else:
		pass
		velocity = (Player.instance.global_position - global_position).normalized() * 150
	move_and_slide()

	look_at(Player.instance.global_position)
	#TODO: spawn enemy when time runs out if not on death

func spawn_mini_enemy() -> void:
	if spawned_enemy == null: return
	else:
		print("Spawner Enemy Spawned ", spawned_enemy.get_path())
	var spawned := spawned_enemy.instantiate()
	spawned.position = position
	add_sibling(spawned)
		
