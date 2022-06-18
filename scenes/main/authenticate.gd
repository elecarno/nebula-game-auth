extends Node2D

var network = NetworkedMultiplayerENet.new()
var port = 1911
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
	
remote func authenticate_player(username, password, player_id):
	var debug_player_str = username + " (" + str(player_id) + ")"
	print("authentication request recieved for " + debug_player_str)
	
	var token
	var gateway_id = get_tree().get_rpc_sender_id()
	var result
	print("starting authentication for " + debug_player_str)
	
	if not playerdata.player_ids.has(username):
		print("user not recognised")
		result = false
	elif not playerdata.player_ids[username].password == password:
		print("incorrect password")
		result = false
	else:
		print("succesful authentication for " + debug_player_str)
		result = true
		
	randomize()
	token = str(randi()).sha256_text() + str(OS.get_unix_time())
	var gameserver = "gameserver1"
	gameservers.distribute_login_token(token, gameserver)
	
	rpc_id(gateway_id, "authentication_results", result, player_id, token)
	print("authentication result for " + debug_player_str + " sent to gateway server")
	
remote func create_account(username, password, player_id):
	var gateway_id = get_tree().get_rpc_sender_id()
	var result
	var message
	if playerdata.player_ids.has(username):
		result = false
		message = 2
	else:
		result = true
		message = 3
		playerdata.player_ids[username] = {"password": password }
		playerdata.save_player_ids()
		
	rpc_id(gateway_id, "create_account_results", result, player_id, message)
