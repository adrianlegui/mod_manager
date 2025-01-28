class_name Data extends Node
## @experimental

## Nombre de la propiedad con la ruta a la escena.
const KEY_SCENE_FILE_PATH: StringName = &"scene_file_path"
## Clave usada en el diccionario de persistencia.
const KEY_PROPERTIES: StringName = &"PROPERTIES"

var _unique: bool = true

func _ready() -> void:
	_add_groups()


func get_data() -> Dictionary:
	var data: Dictionary = {KEY_SCENE_FILE_PATH: scene_file_path}
	data[KEY_PROPERTIES] = get_properties()
	return data


func set_data(data: Dictionary) -> void:
	var properties: Dictionary = data.get(KEY_PROPERTIES, {}) as Dictionary
	if properties.is_empty():
		return
	set_properties(properties)


# Configura las propiedades
func set_properties(properties: Dictionary) -> void:
	for key in properties.keys():
		_set_property(key, properties[key])


func _get_groups() -> PackedStringArray:
	var groups: PackedStringArray = []
	return groups


func _add_groups() -> void:
	for g: String in _get_groups():
		add_to_group(g)


func _set_property(key: String, property: Variant) -> void:
		if key in _get_not_settable_keys():
			return
		var v_node = get(key)
		if v_node == null and typeof(property) == TYPE_DICTIONARY:
			_set_null_node_variable(key, property)
		elif typeof(v_node) == TYPE_OBJECT:
			_set_object_node_variable(key, property)
		elif not _can_be_saved(v_node):
			push_warning(
				"%s.%s es de tipo %s y no puede ser cargado" % [
					name,
					key,
					type_string(typeof(v_node))
				]
			)
			return
		elif _needs_conversion(v_node):
			set(key, str_to_var(property))
		else:
			set(key, property)


## Obtiene la información del nodo.
func get_properties() -> Dictionary:
	var properties: Dictionary = {}
	for key in _get_persistent_keys():
		var v_node = get(key) # variable del nodo
		if typeof(v_node) == TYPE_OBJECT:
			var data: Data = v_node as Data
			if is_instance_valid(data):
				properties[key] = data.get_data()
			else:
				push_warning("variable %s.%s no es de clase Data" % [name, key])
		elif not _can_be_saved(v_node):
			push_warning(
				"%s.%s es de tipo %s y no puede ser guardado" % [
					name,
					key,
					type_string(typeof(v_node))
				]
			)
			continue
		elif _needs_conversion(v_node):
			properties[key] = var_to_str(v_node)
		else:
			properties[key] = v_node

	return properties


func set_unique(value: bool) -> void:
	_unique = value


func is_unique() -> bool:
	return _unique


func delete() -> void:
	_before_deleting()
	if is_unique():
		push_error("No se pudo borrar %s por que es único" % name)
		return

	queue_free()


func _before_deleting() -> void:
	pass


## Devuelve [PackedStringArray] con las claves usadas para configurar el nodo.
func _get_persistent_keys() -> PackedStringArray:
	var keys: PackedStringArray = ["process_mode", "_unique"]
	return keys


## Devuelve [PackedStringArray] con las claves que no tiene que configurar.
func _get_not_settable_keys() -> PackedStringArray:
	var keys: PackedStringArray = []
	keys.append(KEY_SCENE_FILE_PATH)
	return keys


func _needs_conversion(variant: Variant) -> bool:
	var type: int = typeof(variant)
	return (
		type == TYPE_VECTOR2 or
		type == TYPE_VECTOR3 or
		type == TYPE_TRANSFORM2D or
		type == TYPE_TRANSFORM3D
	)


func _can_be_saved(variable) -> bool:
	var type: int = typeof(variable)
	return (
		type == TYPE_BOOL or
		type == TYPE_INT or
		type == TYPE_FLOAT or
		type == TYPE_STRING or
		type == TYPE_STRING_NAME or
		type == TYPE_VECTOR2 or
		type == TYPE_VECTOR3 or
		type == TYPE_PACKED_STRING_ARRAY or
		type == TYPE_TRANSFORM2D or
		type == TYPE_TRANSFORM3D
	)

func _set_null_node_variable(key: String, property: Dictionary) -> void:
	var data: Data = create_data_node(property)

	if not is_instance_valid(data):
		return

	data.name = key.capitalize().replace(" ", "")
	set(key, data)
	var force_readable_name: bool = true
	add_child(data, force_readable_name)


func _set_object_node_variable(key: String, property: Dictionary) -> void:
	var v_node = get(key)
	var data: Data = get(key) as Data
	if is_instance_valid(data):
		data.set_data(property)
	else:
		push_warning("variable %s.%s no es de clase Data" % [name, key])


static func create_data_node(dict: Dictionary) -> Data:
	var data: Data = null
	var path: String = dict.get(KEY_SCENE_FILE_PATH, "") as String
	if path.is_empty():
		push_error("falta scene_file_path")
	else:
		var pck: PackedScene = load(path) as PackedScene
		if pck:
			data = pck.instantiate()
			data.set_data(dict)
	return data
