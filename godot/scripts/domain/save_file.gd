## Save files that survive a write cut short: the new text goes to a temporary file that
## then replaces the old one, so the previous save stays whole until the new one is.
extends RefCounted


## Where a save lives. Tests and the screenshot tour run their own main loop, and the
## build's self-check is run with `--self-check`; their saves go to a folder of their own
## so the player's are never read or replaced.
static func path(file: String) -> String:
	var loop := Engine.get_main_loop()
	var testing := (loop != null and loop.get_script() != null) or OS.get_cmdline_user_args().has("--self-check")
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
	# A replace cut short left the only whole copy in the temporary file: put it in place
	# before the temporary file is written again.
	if not FileAccess.file_exists(target) and FileAccess.file_exists(temporary):
		DirAccess.rename_absolute(ProjectSettings.globalize_path(temporary), ProjectSettings.globalize_path(target))
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(text)
	var stored := file.get_error() == OK
	file.close()
	if not stored:
		return false
	return DirAccess.rename_absolute(ProjectSettings.globalize_path(temporary), ProjectSettings.globalize_path(target)) == OK


## Moves a save that cannot be read out of the way, whole, to `backup`. False when it
## could be neither moved nor copied, in which case it is left where it is.
static func set_aside(target: String, backup: String) -> bool:
	var source := target if FileAccess.file_exists(target) else _temporary(target)
	if not FileAccess.file_exists(source):
		return false
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(backup.get_base_dir()))
	var kept := DirAccess.rename_absolute(ProjectSettings.globalize_path(source), ProjectSettings.globalize_path(backup)) == OK
	if not kept:
		kept = write(backup, FileAccess.get_file_as_string(source))
	if kept:
		remove(target)
	return kept


static func remove(target: String) -> void:
	for file in [target, _temporary(target)]:
		if FileAccess.file_exists(file):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(file))


static func _temporary(target: String) -> String:
	return target + ".tmp"
