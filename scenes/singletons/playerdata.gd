extends Node

var player_ids

func _ready():
	var player_ids_file = File.new()
	player_ids_file.open("res://data/playerdata.json", File.READ)
	var player_ids_json = JSON.parse(player_ids_file.get_as_text())
	player_ids_file.close()
	player_ids = player_ids_json.result
