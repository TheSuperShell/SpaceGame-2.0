extends Button

export(String, "pause", "up", "down") var time_warp = "pause"

onready var label = $Label

func _ready():
	if time_warp == "pause":
		label.text = "||"
	elif time_warp == "up":
		label.text = ">>"
	else:
		label.text = "<<"
