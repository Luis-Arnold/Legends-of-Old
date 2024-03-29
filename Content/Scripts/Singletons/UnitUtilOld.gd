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

enum formationType {
	TRIANGLE,
	RECTANGLE,
	CIRCLE,
	CONCENTRICCIRCLES,
	ANY
}

func getFormationPositions(leader, soldiers, formationPositions, transformation, formationRotation) -> Dictionary:
	# Dictionary to hold soldier objects and their assigned positions
	var soldierAssignments = {}
	var availablePositions = formationPositions.duplicate() # Clone the list to keep track of available positions
	
	availablePositions = availablePositions.map(func(v: Vector2): return v.rotated(formationRotation) + transformation)
	
	# Sort the formation positions by distance from the center of the formation, furthest first
	availablePositions.sort_custom(Callable(self, "sort_positions_desc"))
	
	# Iterate over each soldier to find the closest available position
	for soldier in soldiers:
		soldier.changeRotation(formationRotation)
		var assigned_pos = null
		var closest_dist = INF # Infinity, since we want to minimize this
		
		# Find the closest unassigned formation position
		for pos in availablePositions:
			var dist = soldier.global_position.distance_to(pos)
			
			if dist < closest_dist:
				closest_dist = dist
				assigned_pos = pos
		
		# Assign the closest position to the soldier
		if assigned_pos != null:
			soldierAssignments[soldier] = assigned_pos
			# Remove this position so it's not reused
			availablePositions.erase(assigned_pos)
	
	if is_instance_valid(leader):
		leader.changeRotation(formationRotation)
		soldierAssignments[leader] = Vector2(0,0).rotated(formationRotation) + transformation
	
	return soldierAssignments

# Helper function to sort positions by their distance from the center, in descending order
func sort_positions_desc(a, b):
	var center = Vector2(512, 300) # Assuming center of the formation for sorting
	return center.distance_to(b) < center.distance_to(a)

func matchFormationType(matchType: formationType, unitNum: int, spacing: float, rowWidth: int = 5, unitsPerRing: int = 1) -> Array:
	match matchType:
		formationType.TRIANGLE:
			var positions = []
			var row = 1
			var countInRow = 0
			for i in range(unitNum):
				if countInRow > row:
					row += 1
					countInRow = 0
				var xOffset = (countInRow - row / 2.0) * spacing
				var yOffset = row * spacing
				positions.append(Vector2(xOffset, yOffset))
				
				countInRow += 1
			
			return positions
		formationType.RECTANGLE:
			var positions: Array = []
			# Calculate number of full rows and additional units in the last row
			var fullRows = unitNum / rowWidth
			var extraUnitsInLastRow = unitNum % rowWidth
			
			# Calculate the center position index for the first row
			var centerIndex = rowWidth / 2
			
			for row in range(fullRows):
				var unitsInThisRow = rowWidth
				var xOffsetStart = -(unitsInThisRow - 1) * spacing / 2
				
				for col in range(unitsInThisRow):
					# Skip the middle position for the first row
					if row == 0 and col == centerIndex:
						continue
					positions.append(Vector2(xOffsetStart + col * spacing, row * spacing))
			
			if extraUnitsInLastRow > 0:
				var xOffsetStart = -(extraUnitsInLastRow - 1) * spacing / 2
				for col in range(extraUnitsInLastRow):
					positions.append(Vector2(xOffsetStart + col * spacing, fullRows * spacing))
			
			return positions
		formationType.CIRCLE:
			var positions = []
			var angleStep = 2 * PI / unitNum
			
			for i in range(unitNum):
				var angle = angleStep * i
				var xOffset = cos(angle) * spacing
				var yOffset = sin(angle) * spacing
				positions.append(Vector2(xOffset, yOffset))
			
			return positions
		formationType.CONCENTRICCIRCLES:
			var positions = []
			var currentUnit = 0
			var ring = 0
			
			while currentUnit < unitNum:
				var radius = spacing * ring
				var circumference = 2 * PI * radius
				var unitsInThisRing = min(unitNum - currentUnit, floor(circumference / spacing))
				
				if unitsInThisRing == 0 and radius != 0:
					# This prevents an infinite loop if the spacing is too large for any units to fit in the next ring
					unitsInThisRing = 1
				
				var angleStep = 2 * PI / unitsInThisRing
				
				for i in range(unitsInThisRing):
					var angle = angleStep * i
					var x_offset = cos(angle) * radius
					var y_offset = sin(angle) * radius
					positions.append(Vector2(x_offset, y_offset))
					currentUnit += 1
					
					if currentUnit >= unitNum:
						break
				
				ring += 1
			
			return positions
		_:
			return []
