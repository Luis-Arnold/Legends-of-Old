class_name Unit extends Node2D

const soldierScene = preload('res://Content/Scenes/Soldier/Soldier.tscn')

@export var playerColor: PlayerUtil.playerColor

@export_category('Core')
@export var formation: UnitUtil.formationType

@export var unitDestination: Vector2

@export_category('Soldiers')
@export var leader: Soldier
@export var leaderPosition: Vector2
@export var relativeFormationPositions: Array
@export var absoluteFormationPositions: Array
@export var soldierAssignments: Dictionary
@export var troopSize: int
@export var soldiers: Array

signal unitSelected
signal unitDeselected
signal colorChanged

@export_category('Debug')

func _ready():
	troopSize = 20
	leader = soldierScene.instantiate().duplicate()
	leader.position = Vector2(50 * -1, 0)
	leader.currentUnit = self
	leader.isLeader = true
	leader.scale = Vector2(1.5, 1.5)
	leader.get_node('Body').animation = 'red'
	add_child(leader)
	
	for i in troopSize:
		var soldier: Soldier = soldierScene.instantiate().duplicate()
		soldier.position = Vector2(50 * i, 0)
		soldier.currentUnit = self
		soldiers.append(soldier)
		add_child(soldier)
	
	relativeFormationPositions = UnitUtil.matchFormationType(UnitUtil.formationType.TRIANGLE, troopSize, 30)
	setAbsoluteFormationPositions(relativeFormationPositions, get_global_mouse_position())
	soldierAssignments = UnitUtil.getFormationPositions(leader, soldiers, relativeFormationPositions, get_global_mouse_position(), 0.0)
	
	for soldier in soldierAssignments.keys():
		soldier.formationPosition = soldierAssignments[soldier]
	leader.formationPosition = soldierAssignments[leader]

func selectUnit() -> void:
	print('unit selected')
	CameraUtil.globalSelected = true
	UnitUtil.selectedUnits.append(self)
	for soldier in soldiers:
		soldier.selected = true
		CameraUtil.selectedSoldiers.append(soldier)
	leader.selected = true
	CameraUtil.selectedSoldiers.append(leader)
	emit_signal('unitSelected')

func deselectUnit() -> void:
	CameraUtil.globalSelected = false
	UnitUtil.selectedUnits.erase(self)
	for soldier in soldiers:
		soldier.selected = false
		CameraUtil.selectedSoldiers.erase(soldier)
	leader.selected = false
	CameraUtil.selectedSoldiers.erase(leader)
	emit_signal('unitDeselected')

func _draw():
	for soldier in soldiers:
		draw_circle(soldier.formationPosition, 5, Color.BLACK)
	
#	for i in range(troopSize - 1):
#		draw_line(soldiers[i].position, soldierAssignments.values()[i], Color.RED)

func _process(delta):
	queue_redraw()

func changeColor(newColor: PlayerUtil.playerColor) -> void:
	playerColor = newColor
	for soldier in soldiers:
		soldier.changeColor(newColor)
	leader.changeColor(newColor)
	emit_signal('colorChanged')

func setAbsoluteFormationPositions(relFormationPos, transformation) -> void:
	absoluteFormationPositions = relFormationPos.map(func(v: Vector2): return v + transformation)

func onSoldierDamaged(damagedSoldier: Soldier) -> void:
	pass

func onSoldierDied(deadSoldier: Soldier) -> void:
	troopSize -= 1
	soldiers.erase(deadSoldier)
	UnitUtil.selectedUnits.erase(deadSoldier)
	deadSoldier.queue_free()
