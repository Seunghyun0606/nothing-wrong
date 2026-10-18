## Workstation lock screen.
extends Control

signal signed_in

const Kit := preload("res://scripts/ui/kit.gd")
const P := preload("res://scripts/ui/palette.gd")

var _clock: Label
var _date: Label


func _ready() -> void:
	var background := ColorRect.new()
	background.color = P.DESK
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var column := Kit.vbox(36)
	center.add_child(column)

	_clock = Kit.label("", 96, P.TEXT, false)
	_clock.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_date = Kit.label("", 20, P.MUTED, false)
	_date.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var clock_box := Kit.vbox(0)
	clock_box.add_child(_clock)
	clock_box.add_child(_date)
	column.add_child(clock_box)

	var card := Kit.panel(P.SURFACE, P.BORDER_STRONG, 10, 28)
	card.custom_minimum_size = Vector2(360, 0)
	card.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var body := Kit.vbox(12)
	card.add_child(body)
	var avatar := Kit.avatar("JP", 72)
	avatar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	body.add_child(avatar)
	var name := Kit.heading(GameSession.state["profile"]["name"], 24)
	name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_child(name)
	var station := Kit.label("Nothing Wrong · QA workstation 0142", 14, P.MUTED)
	station.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_child(station)
	body.add_child(Kit.label("Access code", 13, P.MUTED))
	var code := LineEdit.new()
	code.secret = true
	code.text = "first-shift"
	code.text_submitted.connect(func(_text): signed_in.emit())
	body.add_child(code)
	var sign_in := Kit.primary("Sign in", func(): signed_in.emit())
	sign_in.custom_minimum_size = Vector2(0, 46)
	body.add_child(sign_in)
	var note := Kit.label("Training environment · Local session", 13, P.MUTED)
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_child(note)
	column.add_child(card)

	var timer := Timer.new()
	timer.wait_time = 15.0
	timer.autostart = true
	timer.timeout.connect(_tick)
	add_child(timer)
	_tick()


func _tick() -> void:
	var now := Time.get_datetime_dict_from_system()
	var hour: int = now["hour"]
	_clock.text = Kit.clock_text(hour, now["minute"])
	if Settings.language == "ko":
		var days := ["일요일", "월요일", "화요일", "수요일", "목요일", "금요일", "토요일"]
		_date.text = "%d월 %d일 %s" % [now["month"], now["day"], days[now["weekday"]]]
	else:
		var weekdays := ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
		var months := ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
		_date.text = "%s, %s %d" % [weekdays[now["weekday"]], months[now["month"] - 1], now["day"]]
