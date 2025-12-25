@tool
class_name ShowNotTellPlugin
extends EditorPlugin

const EDITOR_CONTROL_NAME = "Behavior Graph"

static var _dock_setting_enabled: bool = false
static var _dock_was_added: bool = false

## The [PackedScene] of the editor node that is added to the Editor.
var gridmap_dock: Control


func _ready() -> void:
	_load_project_settings()
	const EDITOR_TSCN = preload(BehaviorGraph.EDITOR_TSCN_UID)
	if EDITOR_TSCN and EDITOR_TSCN.can_instantiate():
		gridmap_dock = EDITOR_TSCN.instantiate()
		_setup_dock()


func _setup_dock() -> void:
	if BehaviorGraph.is_dock_enabled():
		_create_dock()


func _create_dock() -> void:
	assert(not _dock_was_added, "Trying to create dock after it was created!")
	if not _dock_was_added:
		add_control_to_bottom_panel(gridmap_dock, EDITOR_CONTROL_NAME)
		_dock_was_added = true


func _remove_dock() -> void:
	assert(_dock_was_added, "Dock trying to be removed before it was added!")
	if _dock_was_added:
		remove_control_from_bottom_panel(gridmap_dock)
		gridmap_dock.queue_free()
		_dock_was_added = false


func _load_project_settings() -> void:
	const NAME = BehaviorGraph.DOCK_SETTING_NAME
	const DEFAULT = BehaviorGraph.DOCK_SETTING_DEFAULT

	if not ProjectSettings.has_setting(NAME):
		ProjectSettings.set_setting(NAME, DEFAULT)
	ProjectSettings.set_initial_value(NAME, DEFAULT)
	ProjectSettings.settings_changed.connect(_on_project_settings_changed)


func _on_project_settings_changed() -> void:
	_dock_setting_enabled = BehaviorGraph.is_dock_enabled()
	if not _dock_setting_enabled and _dock_was_added:
		_remove_dock()
	elif _dock_setting_enabled and not _dock_was_added:
		_create_dock()
