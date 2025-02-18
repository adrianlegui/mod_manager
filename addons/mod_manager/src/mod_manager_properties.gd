class_name ModManagerProperties extends Node

## Nombre del fichero que contiene el orden de carga de los mods.
const LOAD_ORDER_FILE: String = "load_order.txt"
## Ruta al directorio donde se encuentran los mods.
const MODS_FOLDER_PATH: String = "user://mods"
## Ruta a la propiedad que contiene la ruta al directorio de mods
const MODS_FOLDER_PATH_PROPERTY: String = "mod_manager/mods_folder_path"
## Extension de los fichero de los mod.
const MOD_EXTENSION: String = "cfg"
## Ruta al directorio de las partidas guardadas.
const SAVEGAME_FOLDER_PATH: String = "user://save"
const GAME_ID_PROPERTY_PATH: String = "mod_manager/game_id"
## Ruta a la propiedad con el nombre del juego
const GAME_NAME_PROPERTY_PATH: String = "application/config/name"
## Parametro usado para Debug.
## Al ser usado las partidas guardadas serán creadas como json.
const NOT_ENCRYPTED_SAVEGAME: String = "--not-encrypted-savedgame"
## Extensión usada en las partidas guardadas cifradas.
const ENCRYPTED_EXTENSION: String = "save"

## Devuelve la ruta del directorio donde se encuentran los mods.
static func get_mods_folder_path() -> String:
	return ProjectSettings.get_setting(
		MODS_FOLDER_PATH_PROPERTY,
		MODS_FOLDER_PATH
	)


static func get_load_order_file_name() -> String:
	return LOAD_ORDER_FILE


static func get_load_order_file_path() -> String:
	return get_mods_folder_path().path_join(get_load_order_file_name())


## Devuelve el directorio de las partidas guardadas.
static func get_savegame_folder_path() -> String:
	return SAVEGAME_FOLDER_PATH


static func get_path_to_savegame(savegame_name: String) -> String:
	return "%s.%s" % [
		get_savegame_folder_path().path_join(savegame_name),
		MOD_EXTENSION if OS.get_cmdline_user_args() else ENCRYPTED_EXTENSION
	]


static func get_game_id() -> String:
	var game_id: String = ProjectSettings.get_setting(
		GAME_ID_PROPERTY_PATH,
		ProjectSettings.get_setting(GAME_NAME_PROPERTY_PATH)
		) as String
	if game_id.is_empty():
		push_error("%s está vacio." % GAME_ID_PROPERTY_PATH)
	return game_id
