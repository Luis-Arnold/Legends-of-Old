class_name Unit3D extends Node3D

const leaderScene = preload('res://Content/Scenes/Soldier/Soldier3D.tscn')
const soldierScene = preload("res://Content/Scenes/Soldier/Soldier3D.tscn")

@export var playerColor: PlayerUtil.playerColor

@export_category('Core')
@export var formation: UnitUtil.formationType
@export var isSelected: bool = false
@export var soldiers: Array = []
@export var leader: Soldier
@export var leaderPosition: Vector2
@export var relativeFormationPositions: Array
@export var absoluteFormationPositions: Array
@export var soldierAssignments: Dictionary
@export var troopSize: int

@export var unitDestination: Vector2

signal unitSelected
signal unitDeselected
signal colorChanged

@export_category('Debug')

func _ready():
	pass

func select():
	isSelected = true
	UnitUtil.selectedUnits.append(self)
	for soldier in soldiers:
		if soldier not in CameraUtil.selectedSoldiers:
			soldier.highlight()
			CameraUtil.selectedSoldiers.append(soldier)

func deselect():
	isSelected = false
	UnitUtil.selectedUnits.erase(self)
	for soldier in soldiers:
		if soldier in CameraUtil.selectedSoldiers:
			soldier.unhighlight()
			CameraUtil.selectedSoldiers.erase(soldier)
