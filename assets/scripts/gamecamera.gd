class_name GameCamera2D
extends Camera2D

export var follow_player_in_scene := false
export var divide_follow : float = 1
export var player_node_path: NodePath
export var is_controlled := false

onready var player_node : KinematicBody2D
onready var game_node : Node2D = get_parent()
onready var this_cam := self

export var shake_decay : float = 8
export var shakyness : float = 0
var shake : Vector2  = Vector2.ZERO

# Timer that controls the beat zoom
var beat_zoom_timer : Timer
# Beat zoom to add to camera zoom
var beat_zoom : float

# Called when the node enters the scene tree for the first time.
func _ready():
	player_node = get_node(player_node_path)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Set position
	if(follow_player_in_scene && !is_controlled):
		self.position = player_node.position/divide_follow

	Globals.shakyness = lerp(Globals.shakyness, 0, shake_decay*delta)

	shake.x = rand_range(-1, 1)*Globals.shakyness
	shake.y = rand_range(-1, 1)*Globals.shakyness
	
	self.offset = Vector2(0.1, 0.1) + shake
	# self.zoom = Vector2(1, 1)
