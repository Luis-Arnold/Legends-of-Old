extends Node

var ownerPlayer: Player

var playerLayers: Dictionary = {}

enum playerColor {
	WHITE,
	BLACK,
	RED,
	GREEN,
	BLUE,
	ANY,
	NONE
}

func _ready():
	pass

func playerColorToString(color) -> String:
	match color:
		playerColor.WHITE:
			return 'white'
		playerColor.BLACK:
			return 'black'
		playerColor.RED:
			return 'red'
		playerColor.GREEN:
			return 'green'
		playerColor.BLUE:
			return 'blue'
		playerColor.ANY:
			return 'any'
		_:
			return 'none'

func isCollisionLayerFriendly(player: Player, layer: int):
	return player.playerCollisionLayer != layer
