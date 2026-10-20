## Save files that survive a write cut short: the new text goes to a temporary file that
## then replaces the old one, so the previous save stays whole until the new one is.
extends RefCounted


## Where a save lives. Tests and the screenshot tour run their own main loop, and their
## saves go to a folder of their own so the player's are never read or replaced.
static func path(file: String) -> String:
	var loop := Engine.get_main_loop()
	var testing := loop != null and loop.get_script() != null
	return ("user://tests/%s" if testing else "user://%s") % file


static func exists(target: String) -> bool:
	return FileAccess.file_exists(target) or FileAccess.file_exists(_temporary(target))


## The saved text. A save whose replace was cut short is still in its temporary file.
static func read(target: String) -> String:
	if FileAccess.file_exists(target):
		return FileAccess.get_file_as_string(target)
	if FileAccess.file_exists(_temporary(target)):
		return FileAccess.get_file_as_string(_temporary(target))
	return ""


static func write(target: String, text: String) -> bool:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(target.get_base_dir()))
	var temporary := _temporary(target)
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(text)
	var stored := file.get_error() == OK
	file.close()
	if not stored:
		return false
	return DirAccess.rename_absolute(ProjectSettings.globalize_path(temporary), ProjectSettings.globalize_path(target)) == OK


static func remove(target: String) -> void:
	for file in [target, _temporary(target)]:
		if FileAccess.file_exists(file):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(file))


static func _temporary(target: String) -> String:
	return target + ".tmp"
