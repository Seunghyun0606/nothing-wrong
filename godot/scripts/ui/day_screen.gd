## Between two days: the player clocks out, the night passes, and the next morning comes
## up before the lock screen. Click anywhere to skip ahead.
extends Control

signal finished

const Kit := preload("res://scripts/ui/kit.gd")
const P := preload("res://scripts/ui/palette.gd")
const StoryClock := preload("res://scripts/domain/story_clock.gd")

## Story times: when the player left, and when they sign in again.
var left := 0
var next := 0
var _done := false


func setup(day: Dictionary) -> void:
	left = int(day.get("left", 0))
	next = int(day.get("next", 0))


func _ready() -> void:
	name = "DayScreen"
	var background := ColorRect.new()
	background.color = Color("#0f1720")
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	var column := Kit.vbox(18)
	center.add_child(column)

	var leaving := Kit.label(Kit.tf("Clocked out · %s %s", [Kit.t(StoryClock.day_name(left)), StoryClock.hhmm(left)]), 18, Color("#9aa5b1"), false)
	leaving.name = "ClockedOut"
	leaving.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(leaving)
	var morning := Kit.vbox(4)
	morning.name = "NextDay"
	var day := Kit.heading(Kit.t(StoryClock.day_name(next)), 56, Color.WHITE)
	day.autowrap_mode = TextServer.AUTOWRAP_OFF
	day.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	morning.add_child(day)
	var time := Kit.label(StoryClock.hhmm(next), 26, Color("#f7c948"), false)
	time.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	time.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	morning.add_child(time)
	morning.add_child(Kit.label(_weeks_later(), 16, Color("#9aa5b1"), false))
	column.add_child(morning)
	(morning.get_child(2) as Label).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	leaving.modulate.a = 0.0
	morning.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(leaving, "modulate:a", 1.0, 0.5)
	tween.tween_interval(1.0)
	tween.tween_property(leaving, "modulate:a", 0.35, 0.4)
	tween.tween_property(morning, "modulate:a", 1.0, 0.7)
	tween.tween_interval(1.6)
	tween.tween_callback(finish)


## How far the story jumps: the next morning, a weekend, or weeks.
func _weeks_later() -> String:
	var days := next / 1440 - left / 1440
	if days >= 7:
		return Kit.tf("%d weeks later", int(round(days / 7.0))) if days >= 14 else Kit.t("A week later")
	if days >= 2:
		return Kit.tf("%d days later", days)
	return Kit.t("The next morning")


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		finish()


func finish() -> void:
	if _done:
		return
	_done = true
	finished.emit()
