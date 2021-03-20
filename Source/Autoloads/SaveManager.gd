extends Node

const saves_path := "user://saves/"

var save_name := "default/"

# Saves the supplied save data to the given path.
func save_data(save: Save, relative_path_to_file: String) -> void:
	var save_file = saves_path.plus_file(save_name + relative_path_to_file)
	var error = ResourceSaver.save(save_file, save,
		ResourceSaver.FLAG_COMPRESS if save_file.ends_with(".res") else 0)
	if error != OK:
		printerr("There was an error when saving level %s to %s (errorcode: %s)." % [name, save_file, error])
	elif save_file.ends_with(".res"):
		ResourceSaver.save(save_file.substr(0, save_file.length()-3) + "tres", save)

# Load the save data from the given path.
func load_data(relative_path_to_file: String) -> Save:
	var save_file: String = saves_path.plus_file(save_name + relative_path_to_file)
	var file: File = File.new()
	if not file.file_exists(save_file):
		print("Save data at %s couldn't be found!" % save_file)
		return null
	
	var save = load(save_file)
	return save

func reset_saves():
	var directory : Directory = Directory.new()
	if directory.dir_exists(saves_path + save_name):
		if directory.open(saves_path + save_name) == OK:
			var _error = directory.list_dir_begin(true, true)
			var file_name = directory.get_next()
			while file_name != "":
				if not directory.current_is_dir():
					var _rem_error = directory.remove(file_name)
				file_name = directory.get_next()
	else:
		directory.make_dir_recursive(saves_path + save_name)
