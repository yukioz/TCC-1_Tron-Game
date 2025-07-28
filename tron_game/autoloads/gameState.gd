extends Node

var selected_players: Array = []

var scores := {}

var animal_data_map := {
	"Porco": {"name": "Porco", "texture": "res://assets/players_sprites/porco.svg", "keybinds": {"left": KEY_LEFT, "right": KEY_RIGHT}, "color": Color.PINK},
	"Águia": {"name": "Águia", "texture": "res://assets/players_sprites/aguia.svg", "keybinds": {"left": KEY_Q, "right": KEY_W}, "color": Color.YELLOW},
	"Serpente": {"name": "Serpente", "texture": "res://assets/players_sprites/serpente.svg", "keybinds": {"left": KEY_Z, "right": KEY_X}, "color": Color.GREEN},
	"Baleia": {"name": "Baleia", "texture": "res://assets/players_sprites/baleia.svg", "keybinds": {"left": KEY_N, "right": KEY_M}, "color": Color.BLUE},
	"Lobo": {"name": "Lobo", "texture": "res://assets/players_sprites/lobo.svg", "keybinds": {"left": KEY_O, "right": KEY_P}, "color": Color.SILVER},
	"Dragão": {"name": "Dragão", "texture": "res://assets/players_sprites/dragao.svg", "keybinds": {"left": KEY_G, "right": KEY_H}, "color": Color.RED},
}
