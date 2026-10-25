## Title: start or continue work, or begin a new game.
extends Control

signal start_requested

const Kit := preload("res://scripts/ui/kit.gd")
const P := preload("res://scripts/ui/palette.gd")

var _content: VBoxContainer
var _notice := ""
var _confirming_reset := false


func _ready() -> void:
	add_child(Kit.backdrop("title", P.SUBTLE))

	# The title card sits over the quiet left side of the picture.
	var left := CenterContainer.new()
	left.set_anchors_preset(Control.PRESET_FULL_RECT)
	left.anchor_right = 0.6
	add_child(left)
	var card := Kit.panel(Color(1, 1, 1, 0.94), Color.TRANSPARENT, 12, 36)
	left.add_child(card)
	_content = Kit.vbox(16)
	_content.custom_minimum_size = Vector2(540, 0)
	card.add_child(_content)

	if GameSession.recovered_from_unreadable_save:
		_notice = "Your previous save could not be read, so a new game was started. The old data was kept as a backup."
	elif WorkspaceSession.recovered_from_unreadable_save:
		_notice = "Your saved notes could not be read, so they start empty. The old notes were kept as a backup."
	_render()


func _render() -> void:
	Kit.clear(_content)
	_content.add_child(Kit.kicker("Quality Operations Simulator"))
	var title := Kit.heading("NOTHING WRONG", 56)
	title.autowrap_mode = TextServer.AUTOWRAP_OFF
	_content.add_child(title)
	_content.add_child(Kit.label("Read the request. Test the product. Prove what happened.", 20, P.MUTED))

	var actions := Kit.hbox(16)
	var start := Kit.primary("Continue work  →" if GameSession.has_progress() else "Start work  →", func(): start_requested.emit())
	start.custom_minimum_size = Vector2(220, 52)
	start.add_theme_font_size_override("font_size", 18)
	actions.add_child(start)
	_content.add_child(actions)

	if _notice != "":
		_content.add_child(Kit.label(_notice, 15, P.WARNING))

	if GameSession.has_progress():
		var reset_row := Kit.hbox(12)
		if _confirming_reset:
			reset_row.add_child(Kit.label("Erase all progress, Evidence, and notes?", 15, P.TEXT, false))
			reset_row.add_child(Kit.link("Yes, start a new game", _reset))
			reset_row.add_child(Kit.link("Cancel", func():
				_confirming_reset = false
				_render()))
		else:
			reset_row.add_child(Kit.link("New game", func():
				_confirming_reset = true
				_render()))
		_content.add_child(reset_row)

	var language := Kit.hbox(8)
	language.name = "Language"
	language.add_child(Kit.label("Language", 14, P.MUTED, false))
	for option in [["ko", "한국어"], ["en", "English"]]:
		var code: String = option[0]
		var choice := Kit.button(option[1], func():
			Settings.set_language(code)
			_render(), "ChoiceButton")
		choice.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		if Settings.language == code:
			choice.add_theme_stylebox_override("normal", Kit.style(P.ACCENT, P.ACCENT, 6, 12, 7))
			choice.add_theme_color_override("font_color", Color.WHITE)
		language.add_child(choice)
	_content.add_child(language)

	var sound := Kit.hbox(8)
	sound.name = "Sound"
	sound.add_child(Kit.label("Sound", 14, P.MUTED, false))
	for option in [[true, "On"], [false, "Off"]]:
		var enabled: bool = option[0]
		var choice := Kit.button(option[1], func():
			Settings.set_sound(enabled)
			_render(), "ChoiceButton")
		if Settings.sound == enabled:
			choice.add_theme_stylebox_override("normal", Kit.style(P.ACCENT, P.ACCENT, 6, 12, 7))
			choice.add_theme_color_override("font_color", Color.WHITE)
		sound.add_child(choice)
	_content.add_child(sound)

	_content.add_child(Kit.label("BUILD 0.4 · GODOT", 12, P.MUTED))


func _reset() -> void:
	GameSession.reset_progress()
	WorkspaceSession.reset()
	DesktopSession.reset_layout()
	_confirming_reset = false
	_notice = "Progress reset. A new shift begins."
	_render()
