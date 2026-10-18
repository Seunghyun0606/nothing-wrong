## Player settings: display language. Korean text comes from res://i18n/ko.json, a map
## from the English source string to its translation. Labels and buttons translate
## their plain text automatically; formatted text goes through Kit.t / Kit.tf.
extends Node

signal language_changed
signal sound_changed

const SETTINGS_PATH := "user://settings.json"
const KO_PATH := "res://i18n/ko.json"
const LANGUAGES := ["ko", "en"]

var language := "en"
var sound := true
var persist := true


func _ready() -> void:
	var translation := Translation.new()
	translation.locale = "ko"
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(KO_PATH))
	if typeof(parsed) == TYPE_DICTIONARY:
		for source in parsed:
			translation.add_message(source, parsed[source])
	TranslationServer.add_translation(translation)

	var saved: Variant = JSON.parse_string(FileAccess.get_file_as_string(SETTINGS_PATH)) if FileAccess.file_exists(SETTINGS_PATH) else null
	if typeof(saved) == TYPE_DICTIONARY and LANGUAGES.has(saved.get("language", "")):
		language = saved["language"]
	else:
		language = "ko" if OS.get_locale_language() == "ko" else "en"
	if typeof(saved) == TYPE_DICTIONARY:
		sound = bool(saved.get("sound", true))
	TranslationServer.set_locale(language)


func set_language(next: String) -> void:
	if not LANGUAGES.has(next) or next == language:
		return
	language = next
	TranslationServer.set_locale(next)
	_save()
	language_changed.emit()


func set_sound(enabled: bool) -> void:
	if enabled == sound:
		return
	sound = enabled
	_save()
	sound_changed.emit()


func _save() -> void:
	if not persist:
		return
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({ "language": language, "sound": sound }))
