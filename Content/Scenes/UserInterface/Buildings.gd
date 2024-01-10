extends Control

@export var buildings: Array = []
@export var hexTileScenePath: String = "res://Content/Scenes/Map/HexTile.tscn"
@export var hexTileScene: PackedScene

func _ready():
	UiUtil.buildingsUI = self
	
	hexTileScene = load(hexTileScenePath)
	var newBuilding: HexTile = hexTileScene.instantiate().duplicate()
	newBuilding._initialize(20, Vector2i.ZERO, 'farm', 'farm', "res://Content/Resources/Visual/3D/Map/Tiles/buildingFarm.glb", "res://Content/Resources/Visual/2D/Icons/Buildings/smallBuildingFarmNE.png", false, false, false, ResourceUtil.resourceType.GOLD)
	buildings.append(newBuilding)
	
	newBuilding = hexTileScene.instantiate().duplicate()
	newBuilding._initialize(100, Vector2i.ZERO, 'tower', 'tower', "res://Content/Resources/Visual/3D/Map/Tiles/buildingTower.glb", "res://Content/Resources/Visual/2D/Icons/Buildings/smallBuildingTowerNE.png", false, true)
	buildings.append(newBuilding)
	
	newBuilding = hexTileScene.instantiate().duplicate()
	newBuilding._initialize(50, Vector2i.ZERO, 'village', 'village', "res://Content/Resources/Visual/3D/Map/Tiles/buildingVillage.glb", "res://Content/Resources/Visual/2D/Icons/Buildings/smallBuildingVillageNE.png")
	buildings.append(newBuilding)
	
	newBuilding = hexTileScene.instantiate().duplicate()
	newBuilding._initialize(200, Vector2i.ZERO, 'castle', 'castle', "res://Content/Resources/Visual/3D/Map/Tiles/buildingCastle.glb", "res://Content/Resources/Visual/2D/Icons/Buildings/smallBuildingCastleNE.png", false, false, true)
	buildings.append(newBuilding)
	
	for building in buildings:
		var buildingButton: Button = Button.new()
		buildingButton.text = building.tileName
		buildingButton.icon = load(building.tileSpritePath)
		buildingButton.connect('pressed', Callable(BuildingUtil, 'setPlacingBuilding').bind(building))
		buildingButton.connect('mouse_entered', Callable(BuildingUtil, 'mouseEnteredButton'))
		buildingButton.connect('mouse_exited', Callable(BuildingUtil, 'mouseExitedButton'))
		
		add_child(buildingButton)
