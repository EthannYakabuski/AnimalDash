extends Node2D

var _achievements_cache: Array[AchievementsClient.Achievement] = []

func achievementsLoaded(): 
	$DebugText.text = $DebugText.text + " inside loaded callback "; 
	AchievementsClient.show_achievements()
	GodotPlayGameServices.android_plugin.showAchievements()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GodotPlayGameServices.android_plugin.showAchievements()
	if AchievementsClient: 
		$DebugText.text = "Achievements client found" 
		#AchievementsClient.achievements_loaded.connect(loadListener)
		AchievementsClient.achievements_loaded.connect(achievementsLoaded);
		AchievementsClient.load_achievements(true)
	else: 
		$DebugText.text = "Achievements client not found"
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func loadListener(): 
	$DebugText.text = "Inside the load listener"
	AchievementsClient.show_achievements();
	if not _achievements_cache.is_empty():
		for achievement: AchievementsClient.Achievement in _achievements_cache:
			$Debug.text = $Debug.text + " processing an ach"
			if achievement.state == AchievementsClient.State.STATE_UNLOCKED:
				var newLabel = Label.new()
				newLabel.text = achievement.achievement_name + "is unlocked"
				add_child(newLabel)
			else: 
				var newLabel = Label.new()
				newLabel.text = achievement.achievement_name + "is locked"
				add_child(newLabel)
	else: 
		$DebugText.text = "no achievements to be found"
