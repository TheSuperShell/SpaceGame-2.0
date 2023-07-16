extends Button

@export var time_warp = "pause" # (String, "pause", "up", "down")

@onready var label = $Label

func _ready():
	if time_warp == "pause":
		label.text = "||"
	elif time_warp == "up":
		label.text = ">>"
	else:
		label.text = "<<"
