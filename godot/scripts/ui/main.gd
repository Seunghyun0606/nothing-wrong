## Switches between the title, lock screen, and workstation desktop.
extends Control

const Kit := preload("res://scripts/ui/kit.gd")
const TitleScreen := preload("res://scripts/ui/title_screen.gd")
const LockScreen := preload("res://scripts/ui/lock_screen.gd")
const DesktopScreen := preload("res://scripts/ui/desktop_screen.gd")

var current: Control


func _ready() -> void:
	theme = Kit.build_theme()
	set_anchors_preset(Control.PRESET_FULL_RECT)
	get_viewport().gui_focus_changed.connect(_on_focus_changed)
	show_title()


## Korean and other IMEs compose text in the OS. Turn the window's IME on whenever a text
## field takes focus, including after the game window regains focus.
func _on_focus_changed(control: Control) -> void:
	if not (control is LineEdit or control is TextEdit):
		return
	DisplayServer.window_set_ime_active(true)
	DisplayServer.window_set_ime_position(Vector2i(control.get_screen_position() + Vector2(0, control.size.y)))


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_IN and is_inside_tree():
		var owner := get_viewport().gui_get_focus_owner()
		if owner != null:
			_on_focus_changed(owner)


func _swap(next: Control) -> void:
	if current:
		current.queue_free()
	current = next
	current.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(current)


func show_title() -> void:
	DesktopSession.set_delivery_enabled(false)
	var screen: Control = TitleScreen.new()
	screen.start_requested.connect(show_lock)
	_swap(screen)


func show_lock() -> void:
	var screen: Control = LockScreen.new()
	screen.signed_in.connect(show_desktop)
	_swap(screen)


func show_desktop() -> void:
	var screen: Control = DesktopScreen.new()
	screen.signed_out.connect(show_title)
	_swap(screen)
