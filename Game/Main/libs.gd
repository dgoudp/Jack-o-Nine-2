####	libs script
#
#		something of a common libraries to hold static common functions
#		currently singleton logging can't be used from here
#


#		returns an array with file names in a specified path and sub directories
static func listFiles(path):
	var folder = Directory.new()
	if !(folder.dir_exists(path)) :
#		logd(str("ERR: listFiles dir does not exist ",path))
		return null
	var filelist = []
	folder.open(path)
#	logd(str("MSG: listFiles processing files for: ",path))
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
#		logd(str("ERR: loadJson file doesn't exist ",path))
		return null
	curfile.open(path,File.READ)
	var data = {}
	data.parse_json(curfile.get_as_text())
	return data


#		load from a file with a dict in each line
static func loadJsonMult(path):
	var curfile = File.new()
	if ( !curfile.file_exists(path)):
#		logd(str("ERR: loadJson file doesn't exist ",path))
		return null
	curfile.open(path,File.READ)
#	logd(str("MSG: loadJsonMult from ",path))
	var data = []
	while ( !curfile.eof_reached()) :
		var line = {}
		line.parse_json(curfile.get_line())
		if ( line.size() != 0):
			data.append(line)
	return data


#		logs and prints verbose messages
#	should be deprecated, used in singleton
#	could be used as something else
static func logd(text = "ERR:",reset = false):
	var config = ConfigFile.new()
	config.load("res://game.cfg")
	var curfile = File.new()
	if reset :
		curfile.open( config.get_value("debug","logpath"),File.WRITE_READ)
	else :
		curfile.open( config.get_value("debug","logpath"),File.READ_WRITE)
	curfile.seek_end()
	if text.begins_with("ERR:") and config.get_value("debug","printERR") :
		print(text)
		curfile.store_line(text)
	elif text.begins_with("WRN:") and config.get_value("debug","printWRN") :
		print(text)
		curfile.store_line(text)
	elif text.begins_with("MSG:") and config.get_value("debug","printMSG") :
		print(text)
		curfile.store_line(text)
	else :
		print(text)
	curfile.close()
	return OK
