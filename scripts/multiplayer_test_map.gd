extends Node3D

var peer = ENetMultiplayerPeer.new()
@export var player_tank: PackedScene

func _ready():
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.peer_connected.connect(_add_player)

func _on_host_pressed():
	peer.create_server(135)
	multiplayer.multiplayer_peer = peer
	_add_player(multiplayer.get_unique_id())

func _on_join_pressed():
	peer.create_client("47.155.52.142", 135)
	multiplayer.multiplayer_peer = peer

func _on_connected_to_server():
	_add_player(multiplayer.get_unique_id())

func _add_player(id := multiplayer.get_unique_id()):
	var player = player_tank.instantiate()
	player.name = str(id)
	player.set_multiplayer_authority(id)
	call_deferred("add_child", player)
