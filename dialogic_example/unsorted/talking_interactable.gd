extends Area2D
class_name TalkingInteractable

##The Dialogic Timeline to play when interacting
@export var timeline: Array[DialogicTimeline]

##The Dialogic Character being interacted with
@export var character: DialogicCharacter = null

## If set to true, the interactable will not repeat its dialogue
## after going through all of its timelines.
## Otherwise, the dialogue will repeat on continual interactions.
@export var one_time: bool = false

@onready var curr_timeline_index: int = 0
@onready var times_played: int = 0
@onready var player_in_range: bool = false
var player: CharacterBody2D

func _ready() -> void:
	Dialogic.timeline_started.connect(_on_timeline_started)
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	for t in timeline:
		Dialogic.preload_timeline(t)
	if character == null:
		push_warning("The dialogic character for " + get_parent().name + "has not been assigned.")

func _input(event: InputEvent) -> void:
	if Dialogic.current_timeline != null:
		return
	
	if not is_active():
		return
	
	if player_in_range && event.is_action_pressed("interact"):
		player.in_dialogue = true #Prevent player movement
		DialogueManager.set_interactable(self) #Give the Dialogue Manager access to the interactable
		DialogueManager.layout = Dialogic.start(timeline[curr_timeline_index])
		get_viewport().set_input_as_handled()

func _on_timeline_started() -> void:
	#This assigns the Dialogic character to the Node in the Scene
	#so that Dialogue knows where to show the text bubble.
	#This should be able to allow for dialogue scenes with multiple talking npcs
	#at once.
	if DialogueManager.layout.has_method("register_character") && character != null:
		DialogueManager.layout.register_character(character, self)

func _on_timeline_ended() -> void:
	if DialogueManager.curr_interactable == self:
		player.in_dialogue = false
		curr_timeline_index += 1
		curr_timeline_index %= timeline.size()
		times_played += 1
		if not is_active():
			player.can_interact = false

func _on_body_entered(body: PhysicsBody2D) -> void:
	if body.name == "Player":
		player_in_range = true
		player = body
		if is_active():
			body.can_interact = true

func _on_body_exited(body: PhysicsBody2D) -> void:
	if body.name == "Player":
		body.can_interact = false
		player_in_range = false

#Returns true if the interactable still has more dialogue
func is_active() -> bool:
	return not (one_time && times_played > timeline.size()-1)