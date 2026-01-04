class_name BehaviorGraph
extends EditorPlugin

const EDITOR_TSCN_UID = "uid://6n7e8d62o8a6"
const DOCK_SETTING_NAME = "addons/show_not_tell/enable_dock"
const DOCK_SETTING_DEFAULT = false


static func is_dock_enabled() -> bool:
	return ProjectSettings.get_setting(
			DOCK_SETTING_NAME, DOCK_SETTING_DEFAULT)
