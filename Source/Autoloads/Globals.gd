extends Node


func reparent_node(node: Node, new_parent: Node, custom_owner: Node = null) -> void:
	var old_parent = node.get_parent()
	if old_parent:
		old_parent.call_deferred("remove_child", node)
	new_parent.call_deferred("add_child", node)
	if custom_owner:
		node.set_deferred("owner", custom_owner)
	else:
		node.set_deferred("owner", new_parent)
