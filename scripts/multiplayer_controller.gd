extends Node3D

@export var player_tank: PackedScene

func _ready():
	multiplayer.peer_connected.connect(_add_player)

func _on_host_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(135)
	multiplayer.multiplayer_peer = peer
	
	_add_player(multiplayer.get_unique_id())

func _on_join_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client("localhost", 135)
	multiplayer.multiplayer_peer = peer
	

func _add_player(id):
	if multiplayer.is_server():
		var player = player_tank.instantiate()
		player.name = str(id)

		# This is crucial: tell Godot this player belongs to the connecting peer
		player.set_multiplayer_authority(id)

		call_deferred("add_child", player)
