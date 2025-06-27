class_name Host extends Control

@export var client_list: VBoxContainer

func add_client(peer: Peer) -> void:
	var label: Label = Label.new()
	label.text = peer.username
	client_list.add_child(label)

func remove_client(peer: Peer) -> void:
	var connected_peer_labels = client_list.get_children()
	var wanted_label_reference: Label
	for label in connected_peer_labels:
		if label.text == peer.username:
			wanted_label_reference = label
			break
	client_list.remove_child(wanted_label_reference)
