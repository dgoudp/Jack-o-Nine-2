####	singleton script
#
#		will handle most scene independent stuff
#

extends Node

var libs = preload("res://Game/Main/libs.gd")


#		whole game common paths
var configPath = "res://game.cfg"
var worldPath = "res://Rome/"
var girlsetPath = "res://Girls/setCRV/"
#		should be made into a config option

#		other options
var logpath = "res://output.log" setget logch
var logmsg = true
var logwrn = true
var logerr = true

#		outputlogging
var logfile = File.new()
var delta = 0.0


#		game databases
var worldBank = {}
var resBank = ResourcePreloader.new()


func _enter_tree():
#	for now loadConf needs a log file
	lognew()
	loadConf()
	logpar()

func _ready():
	logd("MSG: singleton is _ready")
	self.set_process(true)

func _process(del):
	delta += del
#	timed processing
	if delta >= 1.0 :
		logpar()
		delta = 0.0

func _exit_tree():
	logd("MSG: singleton is _exit_tree")
	logend()

#		changes scene getting rid of the current
func changeScene(path):
	var res = ResourceLoader.load(path)
	var newScene = res.instance()
	var curScene = get_tree().get_current_scene()
	if (newScene == null) :
		logd("ERR: g_changeScene newScene is null")
		return FAILED
	get_tree().get_root().add_child(newScene)
	get_tree().set_current_scene(newScene)
	curScene.queue_free()
	return OK


#		initialize configuration with defaults
func loadConf():
	var config = ConfigFile.new()
	var err = config.load( configPath)
#	checking is uneeded and logging only occur after
	if ( err == OK) :
		logd( "MSG: loadConf config loaded successfully")
	else :
		logd( "WRN: loadConf failed to open config")
	checkConf( config,"game","worldPath")
	checkConf( config,"game","girlsetPath")
	checkConf( config,"debug","logpath")
	checkConf( config,"debug","logmsg")
	checkConf( config,"debug","logwrn")
	checkConf( config,"debug","logerr")
	config.save( configPath)

#		cheking if entry exist in cofig
func checkConf( config, sect, key) :
	var value = config.get_value( sect,key)
	if value == null :
		config.set_value( sect, key, get(key))
	else :
		self.set( key, value)


#		global loading of resource and storing
func loadRes(path):
	if (path==null) or (path.is_rel_path()):
		logd(str("ERR: loadRes path is null or relative ",path))
		return null
	if !(File.new().file_exists( str(path))):
		logd( str("WRN: loadRes file missing: ",path))
		return null
	if !(resBank.has_resource(path)):
		var res = ResourceLoader.load( str(path))
		resBank.add_resource(path, res)
		logd( str("MSG: loadRes loaded resource to cache: ",path))
	return resBank.get_resource(path)


#		logs verbosity level to file
func logd(text = "ERR:"):
	if text.begins_with("ERR:") and logerr :
		print(text)
		logfile.store_line(text)
	elif text.begins_with("WRN:") and logwrn :
		print(text)
		logfile.store_line(text)
	elif text.begins_with("MSG:") and logmsg :
		print(text)
		logfile.store_line(text)
	else :
		print(text)
	return OK

#		opens file to log
func lognew( reset=true):
	if reset :
		logfile.open( logpath, File.WRITE_READ)
	else :
		logfile.open( logpath, File.READ_WRITE)
	logfile.seek_end()


#		log write to file
func logend():
	logfile.close()

#		called if logpath changes
func logch( newpath, reset=true):
	if newpath.is_abs_path() :
		if newpath.extension() == "log" :
			logd("MSG: singleton changing log path")
			logend()
			logpath = newpath
			lognew(reset)

#		quickly writes to file and resumes logging
func logpar():
	logend()
	lognew(false)

