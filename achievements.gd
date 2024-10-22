extends Node2D

var _achievements_cache: Array[AchievementsClient.Achievement] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AchievementsClient.achievements_loaded.connect(
		func achievementsLoaded(achievements: Array[AchievementsClient.Achievement]):
			$DebugText.text = $DebugText.text + " inside loaded callback "; 
			AchievementsClient.show_achievements()
	)
	if AchievementsClient: 
		$DebugText.text = "Achievements client found" 
		AchievementsClient.load_achievements(true)
	else: 
		$DebugText.text = "Achievements client not found"
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
