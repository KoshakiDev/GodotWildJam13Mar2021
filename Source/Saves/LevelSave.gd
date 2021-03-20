extends Save
class_name LevelSave

# Holds all the save_data for objects in the level.
# Keys are the indentifiers set by the object (need to be unique),
# the values contain the saved data of that object, which can be anything (variant).
export var object_data := {}
