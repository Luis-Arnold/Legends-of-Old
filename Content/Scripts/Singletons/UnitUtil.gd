extends Node

var selectedUnits: Array = []

@export var relativeUnitPositions: Array
@export var absoluteUnitPositions: Array

enum damageType {
	BLUNT,
	SLASH,
	PIERCE,
	ARCANE,
	POISON,
	FIRE,
	ICE,
	BASE
}

enum unitType {
	ANY
}

enum soldierType {
	ARCHER,
	SPEARMAN,
	KNIGHT
}

enum formationType {
	TRIANGLE,
	RECTANGLE,
	CIRCLE,
	CONCENTRICCIRCLES,
	ANY
}
