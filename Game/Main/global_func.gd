####	Global functions script
#		
#		this script is supposed to fit regular functions that are used on a global scope
#		


extends Node

#var resourceBank = ResourcePreloader.new()

#		Calls for a change in main scene
func g_changeScene(path):
	var res = ResourceLoader.load(path)
	var newScene = res.instance()
	var curScene = get_tree().get_current_scene()
	if (newScene == null) :
		print("ERR: g_changeScene newScene is null")
		return
	get_tree().get_root().add_child(newScene)
	get_tree().set_current_scene(newScene)
	curScene.queue_free()


#		Calls for a close dialog and checks if it already exists
func g_closeDialog():
	print("close dialog called")
	var node = get_tree().get_current_scene().find_node("closeDialog")
	if node == null :
		print("MSG: g_closeDialog called, dialog is new")
		var closeDialog = ResourceLoader.load("res://Game/MainGame/closeDialog.scn")
		get_tree().get_current_scene().add_child(closeDialog.instance())
		get_tree().get_current_scene().find_node("closeDialog").popup_centered()
	else :
		print("MSG: g_closeDialog called, dialog already exists")
		node.popup_centered()



#func g_checkRes(name):
#	if (name==null) or !(typeof(name)==TYPE_STRING):
#		print("ERR: g_checkRes name is null or not string type")
#		return false
#	return resourceBank.has_resource(name)


#		Gets an array with file names in a specified path
func g_listFiles(path):
	var folder = Directory.new()
	if !(folder.dir_exists(path)) :
		print("ERR: dir does not exist ",path)
		return null
	var filelist = []
	folder.open(path)
	print("MSG: g_listFiles processing files for: ",path)
	folder.list_dir_begin()
	var file = folder.get_next()
	while file :
		if (file=="." or file==".."):
			file = folder.get_next()
		elif ( folder.current_is_dir()):
			var sublist = g_listFiles(str(folder.get_current_dir(),"/",file))
			for i in range(sublist.size()):
				var subfile = str(file,"/",sublist[i])
				filelist.append(subfile)
			file = folder.get_next()
		else:
			filelist.append(file)
			file = folder.get_next()
	folder.list_dir_end()
	return filelist



func g_loadJson(path):
	var curfile = File.new()
	if !(curfile.file_exists(path)):
		print("ERR: g_load_Json file doesn't exist ",path)
		return null
	curfile.open(path,File.READ)
	var data = {}
	data.parse_json(curfile.get_as_text())
	print("MSG: g_loadJson data read from: ",path)
	return data


func g_saveJson(path,data):
	var curfile = File.new()
	curfile.open(path,File.WRITE)
	if !(curfile.is_open()):
		print("ERR: g_saveJson file didn't open ",path)
		return false
	curfile.store_line(data.to_json())
	print("MSG: g_saveJson data was written to: ",path)
	curfile.close()
	return true

