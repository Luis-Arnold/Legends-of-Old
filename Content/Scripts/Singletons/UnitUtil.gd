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

func distributeSoldiersAcrossTiles(_selectedUnits, _selectedTiles):
	var _selectedSoldiers = []
	for unit in _selectedUnits:
		unit.currentTiles.clear()
		_selectedSoldiers.append_array(unit.soldiers)
	var totalSoldiers = len(_selectedSoldiers)
	var totalTiles = len(_selectedTiles)
	
	# Calculate the base number of soldiers per tile and the remainder
	@warning_ignore("integer_division")
	var soldiersPerHexTile = totalSoldiers / totalTiles
	var remainder = totalSoldiers % totalTiles
	
	var soldierIndex = 0
	# Distribute units/soldiers across tiles
	for i in range(totalTiles):
		var numSoldiersToAssign = int(soldiersPerHexTile) + int(remainder > 0)
		remainder -= int(remainder > 0)
		
		var soldierPositions = getDistributedPositions(_selectedTiles[i].position, 0.3, numSoldiersToAssign)
		
		for j in range(numSoldiersToAssign):
			if soldierIndex < totalSoldiers:
				_selectedSoldiers[soldierIndex].setTargetPosition(soldierPositions[j])
				if _selectedTiles[i] not in _selectedSoldiers[soldierIndex].currentUnit.currentTiles:
					_selectedSoldiers[soldierIndex].currentUnit.currentTiles.append(_selectedTiles[i])
				soldierIndex += 1

func getDistributedPositions(center: Vector3, radius: float, count: int) -> Array:
	var positions = []
	for i in range(count):
		var angle = 2.0 * PI * i / count
		var x_offset = cos(angle) * radius
		var z_offset = sin(angle) * radius
		positions.append(Vector3(center.x + x_offset, center.y, center.z + z_offset))
	return positions
