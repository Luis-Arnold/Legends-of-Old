class_name Unit extends Node2D

const soldierScene = preload('res://Content/Scenes/Soldier/Soldier.tscn')

@export_category('Core')
@export var formation: UnitUtil.formationType

@export var unitDestination: Vector2

@export_category('Soldiers')
@export var leader: Soldier
@export var leaderPosition: Vector2
@export var troopSize: int
@export var soldiers: Array

@export_category('Debug')
var dSoldiers = []
var dformationPositions = []
var dsoldierAssignments = {}

func _ready():
	troopSize = 5
	for i in troopSize:
		var soldier: Soldier = soldierScene.instantiate().duplicate()
		soldier.position = Vector2(200 * i, 100 * i / 5)
		soldier.currentUnit = self
		soldiers.append(soldier)
		add_child(soldier)
	
	dformationPositions = UnitUtil.matchFormationType(UnitUtil.formationType.TRIANGLE, troopSize, 20)
	dsoldierAssignments = UnitUtil.regroup(soldiers, dformationPositions)

func _draw():
	for v in UnitUtil.matchFormationType(UnitUtil.formationType.TRIANGLE, troopSize, 20):
		draw_circle(v, 3, Color.BLACK)
	
	for i in range(troopSize):
		draw_line(soldiers[i].position, dsoldierAssignments[i], Color.RED)

func _process(delta):
	queue_redraw()

func updateFormation():
	pass
