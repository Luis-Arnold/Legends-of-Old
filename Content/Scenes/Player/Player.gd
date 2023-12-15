class_name Player extends Node2D

var playerColor: PlayerUtil.playerColor
var appOwner: bool

func _ready():
	playerColor = PlayerUtil.playerColor.WHITE
	appOwner = true
	if appOwner:
		PlayerUtil.ownerPlayer = self
