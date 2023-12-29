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

func distributeSoldiersAcrossTiles(selectedUnits, selectedTiles):
	var selectedSoldiers = []
	for unit in selectedUnits:
		unit.currentTiles.clear()
		selectedSoldiers.append_array(unit.soldiers)
	var totalSoldiers = len(selectedSoldiers)
	var totalTiles = len(selectedTiles)
	
	# Calculate the base number of soldiers per tile and the remainder
	var soldiersPerHexTile = totalSoldiers / totalTiles
	var remainder = totalSoldiers % totalTiles
	
	var soldierIndex = 0
	# Distribute units/soldiers across tiles
	for i in range(totalTiles):
		var numSoldiersToAssign = int(soldiersPerHexTile) + int(remainder > 0)
		remainder -= int(remainder > 0)
		
		var soldierPositions = getDistributedPositions(selectedTiles[i].position, 0.1, numSoldiersToAssign)
		
		for j in range(numSoldiersToAssign):
			if soldierIndex < totalSoldiers:
				selectedSoldiers[soldierIndex].setTargetPosition(soldierPositions[j])
				if selectedTiles[i] not in selectedSoldiers[soldierIndex].currentUnit.currentTiles:
					selectedSoldiers[soldierIndex].currentUnit.currentTiles.append(selectedTiles[i])
				soldierIndex += 1

func getDistributedPositions(center: Vector3, radius: float, count: int) -> Array:
	var positions = []
	for i in range(count):
		var angle = 2.0 * PI * i / count
		var x_offset = cos(angle) * radius
		var z_offset = sin(angle) * radius
		positions.append(Vector3(center.x + x_offset, center.y, center.z + z_offset))
	return positions
