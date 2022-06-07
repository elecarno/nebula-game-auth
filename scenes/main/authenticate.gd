extends Node2D

var network = NetworkedMultiplayerENet.new()
var port = 5030
var max_servers = 5

func _ready():
	start_server()
	
func start_server():
	network.create_server(port, max_servers)
	get_tree().set_network_peer(network)
	print("authentication server started")
	
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")
	
func _peer_connected(gateway_id):
	print("gateway " + str(gateway_id) + " connected")
	
func _peer_disconnected(gateway_id):
	print("gateway " + str(gateway_id) + " disconnected")
