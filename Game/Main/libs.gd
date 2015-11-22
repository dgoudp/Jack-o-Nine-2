#tool
#extends Object


#func _run():
#	pass

#		returns an array with file names in a specified path and sub directories
static func listFiles(path):
	var folder = Directory.new()
	if !(folder.dir_exists(path)) :
		logd(str("ERR: listFiles dir does not exist ",path))
		return null
	var filelist = []
	folder.open(path)
	logd(str("MSG: g_listFiles processing files for: ",path))
	folder.list_dir_begin()
	var file = folder.get_next()
	while file :
		if (file=="." or file==".."):
			file = folder.get_next()
		elif ( folder.current_is_dir()):
			var sublist = listFiles(str(folder.get_current_dir(),"/",file))
			for i in range(sublist.size()):
				var subfile = str(file,"/",sublist[i])
				filelist.append(subfile)
			file = folder.get_next()
		else:
			filelist.append(file)
			file = folder.get_next()
	folder.list_dir_end()
	return filelist


#		load a single json data from file
static func loadJson(path):
	var curfile = File.new()
	if !(curfile.file_exists(path)):
		logd(str("ERR: loadJson file doesn't exist ",path))
		return null
	curfile.open(path,File.READ)
	var data = {}
	data.parse_json(curfile.get_as_text())
#	("MSG: g_loadJson data read from: ",path)
	return data


#		logs and prints verbose messages
static func logd(text,reset = false):
	var config = ConfigFile.new()
	config.load("res://engine.cfg")
	var curfile = File.new()
	if reset :
		curfile.open(config.get_value("debug","logpath"),File.WRITE)
	else :
		curfile.open(config.get_value("debug","logpath"),File.READ_WRITE)
	curfile.seek_end()
	if text.begins_with("ERR:") and config.get_value("debug","printERR") :
		print(text)
		curfile.store_line(text)
	elif text.begins_with("MSG:") and config.get_value("debug","printMSG") :
		print(text)
		curfile.store_line(text)
	else :
		print(text)
	curfile.close()
	return OK
