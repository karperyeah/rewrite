extends Node2D

func _ready():
	pass

func _process(delta):
	pass

func _on_Barrier_body_entered(body):
	$Player.position = Vector2(0, -30)
