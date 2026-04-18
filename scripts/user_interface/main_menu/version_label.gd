class_name VersionLabel
extends Label
## Represents a label which displays the current project version.


func _ready() -> void:
	var version = ProjectSettings.get_setting("application/config/version")
	if version == "":
		hide()
	else:
		text = "v" + str(version)
