class_name Unit3D extends Node3D

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

func initializeSoldiers(_troopSize: int = 10, soldierTypeScene: PackedScene = soldierScene):
	for i in _troopSize:
		var soldier = soldierTypeScene.instantiate().duplicate()
		add_child(soldier)
		soldiers.append(soldier)
		soldier.position = Vector3(i*0.2,0.65, 0)
		soldier.currentUnit = self

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

func onSoldierDied(deadSoldier: Soldier3D) -> void:
	troopSize -= 1
	soldiers.erase(deadSoldier)
	UnitUtil.selectedUnits.erase(deadSoldier)
	UnitUtil.selectedUnits = UnitUtil.selectedUnits.filter(func(soldier): return is_instance_valid(soldier))
	deadSoldier.queue_free()
