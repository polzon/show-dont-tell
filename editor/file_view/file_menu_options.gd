extends PopupMenu

var _popup: FileDialog


func _ready() -> void:
	id_pressed.connect(_on_id_pressed)


func _on_id_pressed(id: int) -> void:
	match id:
		0, _:
			print("Option 1 selected")
			_popup = FileDialog.new()
			_popup.popup_centered()
