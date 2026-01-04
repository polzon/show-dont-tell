@tool
class_name ShowNotTellPlugin
extends EditorPlugin

const EDITOR_CONTROL_NAME = "Behavior Graph"
const EDITOR_TSCN = preload(BehaviorGraph.EDITOR_TSCN_UID)

static var _instance: ShowNotTellPlugin

## The [PackedScene] of the editor node that is added to the Editor.
var gridmap_dock: Control
var _dock_was_enabled: bool = false

@onready var editor_enabled: bool = true:
	set = set_editor_enabled


func _init() -> void:
	_instance = self
	ProjectSettings.settings_changed.connect(_on_project_settings_changed)
	_load_project_settings()


func _disable_plugin() -> void:
	_remove_dock()


func set_editor_enabled(enabled: bool) -> void:
	editor_enabled = enabled
	if editor_enabled:
		_create_dock()
	else:
		_remove_dock()


func _create_dock() -> void:
	if not _dock_was_enabled:
		if not gridmap_dock and EDITOR_TSCN and EDITOR_TSCN.can_instantiate():
			gridmap_dock = EDITOR_TSCN.instantiate()
		add_control_to_bottom_panel(gridmap_dock, EDITOR_CONTROL_NAME)
		_dock_was_enabled = true


func _remove_dock() -> void:
	if _dock_was_enabled and gridmap_dock:
		remove_control_from_bottom_panel(gridmap_dock)
		gridmap_dock.queue_free()
		_dock_was_enabled = false


func _load_project_settings() -> void:
	const NAME = BehaviorGraph.DOCK_SETTING_NAME
	const DEFAULT = BehaviorGraph.DOCK_SETTING_DEFAULT

	if not ProjectSettings.has_setting(NAME):
		ProjectSettings.set_setting(NAME, DEFAULT)
	ProjectSettings.set_initial_value(NAME, DEFAULT)


func _on_project_settings_changed() -> void:
	editor_enabled = BehaviorGraph.is_dock_enabled()
