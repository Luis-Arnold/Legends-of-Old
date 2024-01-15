extends Control

@export var buildings: Array = []
@export var hexTileScenePath: String = "res://Content/Scenes/Map/HexTile.tscn"
@export var hexTileScene: PackedScene

func _ready():
	UIUtil.buildingsUI = self
	
	hexTileScene = load(hexTileScenePath)
	var newBuilding: HexTile = hexTileScene.instantiate().duplicate()
	newBuilding._initialize(20, true, true, Vector2i.ZERO, BuildingUtil.buildingType.FARM, "res://Content/Resources/Visual/3D/Map/Tiles/buildingFarm.glb", "res://Content/Resources/Visual/2D/Icons/Buildings/smallBuildingFarmNE.png", false, false, ResourceUtil.resourceType.GOLD)
	buildings.append(newBuilding)
	
	newBuilding = hexTileScene.instantiate().duplicate()
	newBuilding._initialize(100, false, true, Vector2i.ZERO, BuildingUtil.buildingType.TOWER, "res://Content/Resources/Visual/3D/Map/Tiles/buildingTower.glb", "res://Content/Resources/Visual/2D/Icons/Buildings/smallBuildingTowerNE.png", false, true)
	buildings.append(newBuilding)
	
	newBuilding = hexTileScene.instantiate().duplicate()
	newBuilding._initialize(50, false, true, Vector2i.ZERO, BuildingUtil.buildingType.VILLAGE, "res://Content/Resources/Visual/3D/Map/Tiles/buildingVillage.glb", "res://Content/Resources/Visual/2D/Icons/Buildings/smallBuildingVillageNE.png")
	buildings.append(newBuilding)
	
	newBuilding = hexTileScene.instantiate().duplicate()
	newBuilding._initialize(200, true, true, Vector2i.ZERO, BuildingUtil.buildingType.CASTLE, "res://Content/Resources/Visual/3D/Map/Tiles/buildingCastle.glb", "res://Content/Resources/Visual/2D/Icons/Buildings/smallBuildingCastleNE.png", false, false, true)
	buildings.append(newBuilding)
	
	for building in buildings:
		var buildingButton: Button = Button.new()
		buildingButton.text = str(building.cost)
		buildingButton.icon = load(building.tileSpritePath)
		buildingButton.connect('pressed', Callable(BuildingUtil, 'setPlacingBuilding').bind(building))
		buildingButton.connect('mouse_entered', Callable(BuildingUtil, 'mouseEnteredButton'))
		buildingButton.connect('mouse_exited', Callable(BuildingUtil, 'mouseExitedButton'))
		
		add_child(buildingButton)
