extends Node

var player_ids

func _ready():
	var player_ids_file = File.new()
	player_ids_file.open("res://data/playerdata.json", File.READ)
	var player_ids_json = JSON.parse(player_ids_file.get_as_text())
	player_ids_file.close()
	player_ids = player_ids_json.result

func save_player_ids():
	var save_file = File.new()
	save_file.open("res://data/playerdata.json", File.WRITE)
	save_file.store_line(to_json(player_ids))
	save_file.close()
