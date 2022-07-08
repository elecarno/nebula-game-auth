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
	
	var hashed_password
	var token
	var gateway_id = get_tree().get_rpc_sender_id()
	var result
	print("starting authentication for " + debug_player_str)
	
	if not playerdata.player_ids.has(username):
		print("user not recognised")
		result = false
	else:
		var retrieved_salt = playerdata.player_ids[username].salt
		hashed_password = generate_hashed_password(password, retrieved_salt)
		print("retrieved salt and hashed given password")
		
		if not playerdata.player_ids[username].password == hashed_password:
			print("incorrect password")
			result = false
		else:
			print("succesful authentication for " + debug_player_str)
			result = true
			
		randomize()
		token = str(randi()).sha256_text() + str(OS.get_unix_time())
		var gameserver = "gameserver1"
		gameservers.distribute_login_token(token, gameserver)
	
	rpc_id(gateway_id, "authentication_results", result, player_id, token, username)
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
		var salt = generate_salt()
		var hashed_password = generate_hashed_password(password, salt)
		playerdata.player_ids[username] = {"password": hashed_password, "salt": salt }
		playerdata.save_player_ids()
		
	rpc_id(gateway_id, "create_account_results", result, player_id, message)
	
func generate_salt():
	randomize()
	var salt = str(randi()).sha256_text()
	return salt
	
func generate_hashed_password(password, salt):
	var hashed_password = password
	var rounds = pow(2, 18) #8 pow(2, 18) 262144
	while rounds > 0:
		hashed_password = (hashed_password + salt).sha256_text()
		rounds -= 1
	return hashed_password
