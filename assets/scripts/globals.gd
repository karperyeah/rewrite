extends Node

export var shakyness : float = 0.0
export var gTime : float = 0.0

func _ready():
	var window = OS.get_native_handle(OS.WINDOW_HANDLE)

func _process(delta):
	self.gTime += 1*delta
	
	if Input.is_action_just_pressed("toggle_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
