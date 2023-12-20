class_name Player3D extends Node3D

var playerColor: PlayerUtil.playerColor
var playerCollisionLayer: int
var appOwner: bool

func _ready():
	playerColor = PlayerUtil.playerColor.WHITE
	appOwner = true
	if appOwner:
		PlayerUtil.ownerPlayer = self
	
	var ownCollisionLayer = 10
	PlayerUtil.playerLayers[ownCollisionLayer] = self
	playerCollisionLayer = ownCollisionLayer 
