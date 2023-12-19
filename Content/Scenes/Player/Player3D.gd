class_name Player3D extends Node3D

var playerColor: PlayerUtil.playerColor

func _ready():
	PlayerUtil.playerOwner = self
