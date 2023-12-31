extends Control

var buildings: Array = []
var hexTileScenePath = "res://Content/Scenes/Map/HexTile.tscn"
var hexTileScene: PackedScene

func _ready():
	hexTileScene = load(hexTileScenePath)
	var newBuilding = hexTileScene.instantiate().duplicate()
	newBuilding._initialize('tower', 'tower', "res://Content/Resources/Visual/3D/Map/Tiles/buildingFarm.glb", "res://Content/Resources/Visual/2D/Icons/Buildings/smallBuildingFarmNE.png")
	buildings.append(newBuilding)
	
	newBuilding = hexTileScene.instantiate().duplicate()
	newBuilding._initialize('tower', 'tower', "res://Content/Resources/Visual/3D/Map/Tiles/buildingTower.glb", "res://Content/Resources/Visual/2D/Icons/Buildings/smallBuildingTowerNE.png")
	buildings.append(newBuilding)
	
	newBuilding = hexTileScene.instantiate().duplicate()
	newBuilding._initialize('tower', 'tower', "res://Content/Resources/Visual/3D/Map/Tiles/buildingVillage.glb", "res://Content/Resources/Visual/2D/Icons/Buildings/smallBuildingVillageNE.png")
	buildings.append(newBuilding)
	
	for building in buildings:
		var buildingButton: Button = Button.new()
		buildingButton.icon = load(building.tileSpritePath)
		buildingButton.connect('pressed', Callable(BuildingUtil, 'setPlacingBuilding').bind(building))
		%BuildingButtonGrid.add_child(buildingButton)
