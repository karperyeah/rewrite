extends Node2D

export var color : Color
onready var animation_player : AnimationPlayer = get_node("AnimationPlayer")
onready var self_kill_timer : Timer

func _ready():
	self.modulate = color
	self_kill_timer = Timer.new()
	add_child(self_kill_timer)
	self_kill_timer.wait_time = 1.0
	self_kill_timer.one_shot = true
	self_kill_timer.connect("timeout", self, "_timeout")
	self_kill_timer.start()
	self.position += Vector2(rand_range(-5, 5), rand_range(-5, 5))
	animation_player.play("Explode")

func _timeout():
	queue_free()
