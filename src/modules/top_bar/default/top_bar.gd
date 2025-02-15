extends Control
# TODO: Have an option to switch the order of these buttons from right to left
# TODO: Make this top_bar invisible in zen mode
# TODO: Make icon open a menu to see about, donation page, changelog, ...

var move_window: bool = false
var move_start: Vector2i


func _ready() -> void:
	find_child("ProjectButton").visible = false
	ProjectManager._on_project_loaded.connect(on_startup_closed)
	ProjectManager._on_title_changed.connect(on_project_title_change)
	ProjectManager._on_saved.connect(on_project_saved)
	ProjectManager._on_unsaved_changes.connect(on_project_unsaved_changes)
	check_zen(SettingsManager.get_zen_mode())
	SettingsManager._on_zen_switched.connect(check_zen)


# This is the functionality to move the window as we extent_to_title
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == 1:
		if !move_window:
			move_start = get_viewport().get_mouse_position()
		move_window = event.is_pressed()


func _process(_delta: float) -> void:
	if !move_window: return
	var mouse_delta = Vector2i(get_viewport().get_mouse_position()) - move_start
	get_window().position += mouse_delta


func on_startup_closed() -> void:
	find_child("ProjectButton").visible = true


func on_project_title_change() -> void:
	$ProjectTitleLabel.text = ProjectManager.title


func on_project_saved() -> void:
	if $ProjectTitleLabel.text[-1] == '*':
		$ProjectTitleLabel.text = $ProjectTitleLabel.text.trim_suffix('*')


func on_project_unsaved_changes() -> void:
	if $ProjectTitleLabel.text[-1] != '*':
		$ProjectTitleLabel.text += '*'


func _on_project_button_pressed() -> void:
	ProjectManager._on_open_project_settings.emit()


func _on_settings_button_pressed() -> void:
	SettingsManager._on_open_settings.emit()


func _on_minimize_button_pressed() -> void:
	get_window().set_mode(Window.MODE_MINIMIZED)
	get_tree().current_scene._on_window_mode_switched.emit()


func _on_switch_mode_button_pressed() -> void:
	match get_window().mode:
		Window.MODE_WINDOWED:  
			get_window().set_mode(Window.MODE_FULLSCREEN)
		Window.MODE_FULLSCREEN : 
			get_window().set_mode(Window.MODE_WINDOWED)
	get_tree().current_scene._on_window_mode_switch.emit()



func _on_exit_button_pressed() -> void:
	# TODO: Check if unsaved changes and first display a message
	#       asking if they want to save or not
	get_tree().quit()


func check_zen(value: bool) -> void:
	find_child("MinimizeButton").visible = !value
	find_child("SwitchModeButton").visible = !value
	find_child("ExitButton").visible = !value
