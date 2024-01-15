extends Control

@export var unitScene: PackedScene

func _ready():
	UIUtil.recruitingUI = self
	
	visible = false
