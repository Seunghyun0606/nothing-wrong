## Workstation lock screen.
extends Control

signal signed_in

const Kit := preload("res://scripts/ui/kit.gd")
const P := preload("res://scripts/ui/palette.gd")
const StoryClock := preload("res://scripts/domain/story_clock.gd")

var _clock: Label
var _date: Label
var _signed := false


func _ready() -> void:
	add_child(Kit.backdrop("lock", P.DESK))
	# A light veil keeps the clock readable over the morning window.
	var veil := ColorRect.new()
	veil.color = Color(1, 1, 1, 0.35)
	veil.set_anchors_preset(Control.PRESET_FULL_RECT)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(veil)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var column := Kit.vbox(36)
	center.add_child(column)

	_clock = Kit.label("", 96, P.TEXT, false)
	_clock.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_date = Kit.label("", 20, P.TEXT, false)
	Kit.halo(_clock, 10)
	Kit.halo(_date, 6)
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
	var station := Kit.label("Northstar · QA workstation 0142", 14, P.MUTED)
	station.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_child(station)
	body.add_child(Kit.label("Access code", 13, P.MUTED))
	var code := LineEdit.new()
	code.secret = true
	code.text = "first-shift"
	code.text_submitted.connect(func(_text): _sign_in())
	body.add_child(code)
	var sign_in := Kit.primary("Sign in", _sign_in)
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


## The story's clock: the time the player signs in (the next morning after clocking out).
## Enter and a click in the same frame sign in once.
func _sign_in() -> void:
	if _signed:
		return
	_signed = true
	signed_in.emit()


func _tick() -> void:
	var at := DesktopSession.login_time()
	if at >= 0:
		_clock.text = Kit.clock_text((at % 1440) / 60, at % 60)
		_date.text = Kit.t(StoryClock.day_name(at))
		return
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
