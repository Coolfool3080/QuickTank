extends Node3D

const PLAYER = preload("res://assets/player_tank_new.tscn")

var peer = ENetMultiplayerPeer.new()

func _on_host_pressed():
	peer.create_server(135)
	multiplayer.multiplayer_peer = peer
	add_player(multiplayer.get_unique_id())
	
	multiplayer.peer_connected.connect(
		func(pid):
			print("Peer " + str(pid) + " has joined the server")
			add_player(pid)
	)

func _on_join_pressed():
	peer.create_client("localhost", 135)
	multiplayer.multiplayer_peer = peer

func add_player(pid):
	var player = PLAYER.instantiate()
	player.name = str(pid)
	add_child(player,true)
