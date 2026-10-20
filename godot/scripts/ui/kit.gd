## Small helpers for building UI in code, plus the office Theme.
extends RefCounted

const P := preload("res://scripts/ui/palette.gd")
const KeyTerms := preload("res://scripts/domain/key_terms.gd")

const STATUS_LABELS := {
	"NEW": "New", "ACCEPTED": "Accepted", "TESTING": "In testing", "REPORTED": "Reported",
	"REVIEWED": "Reviewed", "RESOLVED": "Resolved", "NO_ISSUE": "No issue",
}

static var _bold: FontVariation


## Translates an English source string for the current language.
static func t(text: String) -> String:
	return str(TranslationServer.translate(text))


## Translates a format template, then fills it.
static func tf(template: String, args: Variant) -> String:
	return t(template) % args


static func status_label(status: String) -> String:
	return t(STATUS_LABELS.get(status, status))


static func bold_font() -> Font:
	if _bold == null:
		_bold = FontVariation.new()
		_bold.base_font = ThemeDB.fallback_font
		_bold.variation_embolden = 0.7
	return _bold


static func style(bg: Color, border: Color = Color.TRANSPARENT, radius: int = 6, pad_x: int = 0, pad_y: int = 0, border_width: int = 1) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = bg
	box.border_color = border
	if border.a > 0.0:
		box.set_border_width_all(border_width)
	box.set_corner_radius_all(radius)
	box.content_margin_left = pad_x
	box.content_margin_right = pad_x
	box.content_margin_top = pad_y
	box.content_margin_bottom = pad_y
	box.anti_aliasing = true
	return box


static func build_theme() -> Theme:
	var theme := Theme.new()
	theme.default_font_size = 15
	theme.set_color("font_color", "Label", P.TEXT)

	for type in ["Button", "OptionButton", "MenuButton"]:
		theme.set_stylebox("normal", type, style(P.SURFACE, P.BORDER_STRONG, 6, 12, 7))
		theme.set_stylebox("hover", type, style(P.SUBTLE, P.ACCENT, 6, 12, 7))
		theme.set_stylebox("pressed", type, style(P.ACCENT_SOFT, P.ACCENT, 6, 12, 7))
		theme.set_stylebox("hover_pressed", type, style(P.ACCENT_SOFT, P.ACCENT, 6, 12, 7))
		theme.set_stylebox("disabled", type, style(P.SUBTLE, P.BORDER, 6, 12, 7))
		theme.set_stylebox("focus", type, style(Color.TRANSPARENT, P.ACCENT, 6, 12, 7, 2))
		theme.set_color("font_color", type, P.TEXT)
		theme.set_color("font_hover_color", type, P.TEXT)
		theme.set_color("font_pressed_color", type, P.ACCENT)
		theme.set_color("font_hover_pressed_color", type, P.ACCENT)
		theme.set_color("font_focus_color", type, P.TEXT)
		theme.set_color("font_disabled_color", type, P.MUTED)

	theme.add_type("PrimaryButton")
	theme.set_type_variation("PrimaryButton", "Button")
	theme.set_stylebox("normal", "PrimaryButton", style(P.ACCENT, P.ACCENT, 6, 16, 9))
	theme.set_stylebox("hover", "PrimaryButton", style(P.ACCENT_HOVER, P.ACCENT_HOVER, 6, 16, 9))
	theme.set_stylebox("pressed", "PrimaryButton", style(P.ACCENT_HOVER, P.ACCENT_HOVER, 6, 16, 9))
	theme.set_stylebox("disabled", "PrimaryButton", style(P.BORDER, P.BORDER, 6, 16, 9))
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
		theme.set_color(state, "PrimaryButton", Color.WHITE)
	theme.set_color("font_disabled_color", "PrimaryButton", P.MUTED)

	theme.add_type("FlatLink")
	theme.set_type_variation("FlatLink", "Button")
	var flat := style(Color.TRANSPARENT, Color.TRANSPARENT, 4, 2, 2)
	for state in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
		theme.set_stylebox(state, "FlatLink", flat)
	theme.set_stylebox("focus", "FlatLink", style(Color.TRANSPARENT, P.ACCENT, 4, 2, 2, 1))
	for state in ["font_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
		theme.set_color(state, "FlatLink", P.ACCENT)
	theme.set_color("font_hover_color", "FlatLink", P.ACCENT_HOVER)

	theme.add_type("ChoiceButton")
	theme.set_type_variation("ChoiceButton", "Button")
	theme.set_stylebox("normal", "ChoiceButton", style(P.SURFACE, P.BORDER, 6, 12, 9))
	theme.set_stylebox("hover", "ChoiceButton", style(P.SUBTLE, P.ACCENT, 6, 12, 9))
	theme.set_stylebox("pressed", "ChoiceButton", style(P.ACCENT_SOFT, P.ACCENT, 6, 12, 9, 2))
	theme.set_stylebox("hover_pressed", "ChoiceButton", style(P.ACCENT_SOFT, P.ACCENT, 6, 12, 9, 2))
	theme.set_stylebox("disabled", "ChoiceButton", style(P.SUBTLE, P.BORDER, 6, 12, 9))

	for type in ["LineEdit", "TextEdit"]:
		theme.set_stylebox("normal", type, style(P.SURFACE, P.BORDER_STRONG, 6, 10, 8))
		theme.set_stylebox("focus", type, style(P.SURFACE, P.ACCENT, 6, 10, 8, 2))
		theme.set_stylebox("read_only", type, style(P.SUBTLE, P.BORDER, 6, 10, 8))
		theme.set_color("font_color", type, P.TEXT)
		theme.set_color("font_placeholder_color", type, P.MUTED)
		theme.set_color("caret_color", type, P.ACCENT)
		theme.set_color("selection_color", type, P.ACCENT_SOFT)

	for type in ["CheckBox", "CheckButton"]:
		theme.set_color("font_color", type, P.TEXT)
		theme.set_color("font_hover_color", type, P.TEXT)
		theme.set_color("font_pressed_color", type, P.TEXT)
		theme.set_color("font_hover_pressed_color", type, P.TEXT)
		theme.set_color("font_focus_color", type, P.TEXT)
		var plain := style(Color.TRANSPARENT, Color.TRANSPARENT, 4, 4, 4)
		for state in ["normal", "hover", "pressed", "hover_pressed"]:
			theme.set_stylebox(state, type, plain)

	theme.set_stylebox("panel", "PanelContainer", style(P.SURFACE, P.BORDER, 6))
	theme.set_stylebox("panel", "PopupMenu", style(P.SURFACE, P.BORDER_STRONG, 6, 6, 6))
	theme.set_color("font_color", "PopupMenu", P.TEXT)
	theme.set_color("font_hover_color", "PopupMenu", P.ACCENT)
	theme.set_stylebox("hover", "PopupMenu", style(P.ACCENT_SOFT, Color.TRANSPARENT, 4))
	theme.set_stylebox("panel", "TooltipPanel", style(P.TEXT, Color.TRANSPARENT, 4, 8, 5))
	theme.set_color("font_color", "TooltipLabel", Color.WHITE)
	theme.set_stylebox("separator", "HSeparator", style(P.BORDER, Color.TRANSPARENT, 0))
	theme.set_constant("separation", "HSeparator", 1)
	return theme


static func label(text: String, size: int = 15, color: Color = P.TEXT, wrap: bool = true) -> Label:
	var node := Label.new()
	node.text = text
	node.add_theme_font_size_override("font_size", size)
	node.add_theme_color_override("font_color", color)
	if wrap:
		node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return node


## Wrapped story text (already translated) with its key terms in bold.
static func rich(text: String, size: int = 15, color: Color = P.TEXT) -> RichTextLabel:
	var node := RichTextLabel.new()
	node.bbcode_enabled = true
	node.fit_content = true
	node.scroll_active = false
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	node.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	node.add_theme_font_size_override("normal_font_size", size)
	node.add_theme_font_size_override("bold_font_size", size)
	node.add_theme_font_override("bold_font", bold_font())
	node.add_theme_color_override("default_color", color)
	node.text = KeyTerms.mark(text)
	return node


static func heading(text: String, size: int = 22, color: Color = P.TEXT) -> Label:
	var node := label(text, size, color)
	node.add_theme_font_override("font", bold_font())
	return node


static func kicker(text: String, color: Color = P.ACCENT) -> Label:
	var node := label(t(text).to_upper(), 12, color, false)
	node.add_theme_font_override("font", bold_font())
	return node


static func button(text: String, on_press: Callable, variation: String = "") -> Button:
	var node := Button.new()
	node.text = text
	node.theme_type_variation = variation
	node.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	node.pressed.connect(on_press)
	return node


static func primary(text: String, on_press: Callable) -> Button:
	return button(text, on_press, "PrimaryButton")


static func link(text: String, on_press: Callable) -> Button:
	var node := button(text, on_press, "FlatLink")
	node.alignment = HORIZONTAL_ALIGNMENT_LEFT
	node.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	return node


## A link whose text wraps (an address, a sentence), so a narrow window stays narrow.
static func long_link(text: String, on_press: Callable) -> Button:
	var node := link(text, on_press)
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return node


static func vbox(separation: int = 8) -> VBoxContainer:
	var node := VBoxContainer.new()
	node.add_theme_constant_override("separation", separation)
	return node


static func hbox(separation: int = 8) -> HBoxContainer:
	var node := HBoxContainer.new()
	node.add_theme_constant_override("separation", separation)
	return node


static func panel(bg: Color, border: Color = Color.TRANSPARENT, radius: int = 6, pad: int = 12) -> PanelContainer:
	var node := PanelContainer.new()
	node.add_theme_stylebox_override("panel", style(bg, border, radius, pad, pad))
	return node


static func margin(child: Control, left: int, top: int, right: int, bottom: int) -> MarginContainer:
	var node := MarginContainer.new()
	node.add_theme_constant_override("margin_left", left)
	node.add_theme_constant_override("margin_top", top)
	node.add_theme_constant_override("margin_right", right)
	node.add_theme_constant_override("margin_bottom", bottom)
	node.add_child(child)
	return node


static func spacer() -> Control:
	var node := Control.new()
	node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return node


static func scroll(child: Control) -> ScrollContainer:
	var node := ScrollContainer.new()
	node.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	node.size_flags_vertical = Control.SIZE_EXPAND_FILL
	node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	child.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	node.add_child(child)
	return node


static func clear(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()


static func avatar(initials: String, size: int = 36) -> PanelContainer:
	var holder := panel(P.ACCENT_SOFT, P.BORDER_STRONG, int(size / 2.0), 0)
	holder.custom_minimum_size = Vector2(size, size)
	holder.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	holder.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	var text := label(initials, int(size * 0.36), P.ACCENT, false)
	text.add_theme_font_override("font", bold_font())
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	holder.add_child(text)
	return holder


static func initials(name: String) -> String:
	var result := ""
	for part in name.replace(".", " ").split(" ", false):
		result += part.substr(0, 1)
	return result.substr(0, 2).to_upper()


## Marks a node as an observable product element for Evidence capture.
static func evidence(node: Control, target: String, label_text: String, value: String = "") -> Control:
	node.set_meta("evidence_target", target)
	node.set_meta("evidence_label", label_text)
	if value != "":
		node.set_meta("evidence_value", value)
	return node


static func clock_text(hour: int, minute: int) -> String:
	var twelve := 12 if hour % 12 == 0 else hour % 12
	if TranslationServer.get_locale().begins_with("ko"):
		return "%s %d:%02d" % ["오후" if hour >= 12 else "오전", twelve, minute]
	return "%d:%02d %s" % [twelve, minute, "PM" if hour >= 12 else "AM"]


static func time_text(unix_ms: float) -> String:
	var bias: int = int(Time.get_time_zone_from_system().get("bias", 0))
	var dict := Time.get_datetime_dict_from_unix_time(int(unix_ms / 1000.0) + bias * 60)
	return "%02d:%02d:%02d" % [dict["hour"], dict["minute"], dict["second"]]
