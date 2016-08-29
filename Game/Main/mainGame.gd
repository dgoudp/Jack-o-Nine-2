####	Main Game script
#	
#		This object will handle most of the game main interface
#		Including main navigation and panels
#		extra screens like invetory and stats, will also be child of this node

extends Node

#		type constants for location
const Def_unavailable = -1
const Def_disable = 0
const Def_location = 1
const Def_dialog = 2
const Def_script = 3

var libs = preload("res://Game/Main/libs.gd")
var logd = FuncRef.new()
var loadRes = FuncRef.new()

#		world path, is an global option in singleton
var worldPath

#		database for most game files
var worldBank = {}
var resBank = ResourcePreloader.new()

#		tracking of current location is needed
var current_local = {}
var SceneA = ResourceLoader.load("res://Game/Main/SceneA.tscn").instance()


func _enter_tree():
	logd.set_instance( get_node("/root/singleton"))
	logd.set_function( "logd")
	loadRes.set_instance( get_node("/root/singleton"))
	loadRes.set_function( "loadRes")
	worldBank = get_node("/root/singleton").get("worldBank")
	resBank = get_node("/root/singleton").get("resBank")
	#worldPath = get_node("/root/singleton").get("worldPath")
	


func _ready():
	self.add_child( SceneA)
	logd.call_func( "MSG: mainGame is _ready")
	loadWorld( get_node("/root/singleton").get("pathWorld"))
	SceneA.call_deferred("change_local","rome_main")



#		This calls on all world data files to be loaded into worldBank
func loadWorld(path = ""):
	if path.empty() :
		logd.call_func( "ERR: loadWorld path is empty")
		return FAILED
	var filelist = libs.listFiles(path)
	if filelist==null :
		logd.call_func( "ERR: loadWorld file list came empty")
		return FAILED
	for i in range(filelist.size()):
		if ( filelist[i].find("template")!=-1) :
			continue
		elif ( filelist[i].extension()=="json") :
			var data = libs.loadJson( str(path,filelist[i]))
			if data==null :
				logd.call_func( str("ERR: loadWorld failed to load data: ",filelist[i]))
				continue
			elif !data.has("name") or (data["name"]==""):
				logd.call_func( str("WRN: loadWrold data has no name: ",filelist[i]))
				continue
			elif !data.has("type") or (typeof(data["type"])!=TYPE_REAL):
				logd.call_func( str("WRN: loadWorld data has no type: ",filelist[i]))
				continue
			elif worldBank.has(data["name"]) :
				logd.call_func( str("WRN: loadWorld already has data: ",data["name"]))
				continue
			else :
				logd.call_func( str("MSG: loadWorld loaded data ",data["name"]))
				worldBank[data["name"]] = data
		else :
			continue
	return OK





