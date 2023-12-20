class_name Player extends Node2D

var playerColor: PlayerUtil.playerColor
var playerCollisionLayer: int
var appOwner: bool

func _ready():
	playerColor = PlayerUtil.playerColor.WHITE
	appOwner = true
#	if appOwner:
#		PlayerUtil.ownerPlayer = self
	
	var ownCollisionLayer = 10
	PlayerUtil.playerLayers[ownCollisionLayer] = self
	playerCollisionLayer = ownCollisionLayer 
