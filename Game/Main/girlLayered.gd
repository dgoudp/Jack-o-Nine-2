####	Layer girl panel
#
#		simple panel to test the build of layered girls
#

extends Node

var libs = preload("res://Game/Main/libs.gd")

export(String, DIR) var prepath = "res://Girls/setCRV/OV001/"

var layerList = []		# array with all info loaded
var girlParList = {}	# reference for parameters id
var girlParam = {}		# actually selected parameters

var resBank = ResourcePreloader.new()

func _enter_tree():
	libs.logd("MSG: girlLayered test scene",true)
#	layerList = libs.call_deferred("loadJsonMult",str(prepath,"info.json"))
	layerList = libs.loadJsonMult(str(prepath,"info.json"))
	pass

func _ready():
#	layerList = libs.loadJsonMult(str(prepath,"info.json"))
	if layerList == null :
		libs.logd("ERR: layerList null")
#		get_tree().quit()
	else :
		libs.logd("MSG: girlTaglist loaded, attempt loading of images")
		call_deferred("initParamList")
#		call_deferred("printlayerList")
	pass


func loadRes(path):
	if (path==null) or !(path.is_rel_path()):
		libs.logd(str("ERR: loadRes path is null or not relative ",path))
		return null
	if !(File.new().file_exists(str(prepath,path))):
		libs.logd(str("WRN: loadRes file missing: ",path))
		return null
	if !(resBank.has_resource(path)):
		var res = ResourceLoader.load(str(prepath,path))
		resBank.add_resource(path, res)
		libs.logd(str("MSG: loadRes loaded resource to cache: ",path))
	return resBank.get_resource(path)

func initParamList() :
	#	Basic parameters
	girlParam["back"] = ["background"]
	girlParam["body"] = ["body"]
	girlParam["head"] = ["head"]
	girlParam["Col"] = ["ColA"]
	#	Attributed parameters
	girlParList["Skn"] = ["SknA","SknB","SknC","SknD"] 
	girlParam["Skn"] = girlParList["Skn"][get_node("selpanel/center/vbox/hbox/options/Skn").get_selected()]
	girlParList["Bst"] = ["BstA","BstB","BstC","BstD"] 
	girlParam["Bst"] = girlParList["Bst"][get_node("selpanel/center/vbox/hbox/options/Bst").get_selected()]
	girlParList["Nip"] = ["NipA","NipB"] 
	girlParam["Nip"] = girlParList["Nip"][get_node("selpanel/center/vbox/hbox/options/Nip").get_selected()]
	girlParList["Npc"] = ["NpCA","NpCB"] 
	girlParam["Npc"] = girlParList["Npc"][get_node("selpanel/center/vbox/hbox/options/Npc").get_selected()]
	girlParList["Hrb"] = ["none","HrbA","HrbB","HrbC","HrbD","HrbE","HrbF","HrbE","HrbG"] 
	girlParam["Hrb"] = girlParList["Hrb"][get_node("selpanel/center/vbox/hbox/options/Hrb").get_selected()]
	girlParList["Hrs"] = ["none","HrsA"] 
	girlParam["Hrs"] = girlParList["Hrs"][get_node("selpanel/center/vbox/hbox/options/Hrs").get_selected()]
	girlParList["Hrf"] = ["none","HrfA","HrfB","HrfC","HrfD","HrfE","HrfF","HrfE","HrfG"] 
	girlParam["Hrf"] = girlParList["Hrf"][get_node("selpanel/center/vbox/hbox/options/Hrf").get_selected()]
	girlParList["Eye"] = ["EyeA","EyeB"] 
	girlParam["Eye"] = girlParList["Eye"][get_node("selpanel/center/vbox/hbox/options/Eye").get_selected()]
	girlParList["Eyb"] = ["EybA","EybB"] 
	girlParam["Eyb"] = girlParList["Eyb"][get_node("selpanel/center/vbox/hbox/options/Eyb").get_selected()]
	girlParList["Expression"] = ["expression01","expression02","expression03","expression04","expression05","expression06","expression07","expression08","expression09","expression10","expression11"] 
	girlParam["Expression"] = girlParList["Expression"][get_node("selpanel/center/vbox/hbox/options/Expression").get_selected()]
	

func genImage () :
	var ref = get_node("ReferenceFrame")
	while (ref.get_child_count() > 0) :
		ref.get_child(0).free()
	printParams()
	var params = []
	var filtList = []
	for p in girlParam :
		params.append(girlParam[p])
		print("Param added: ",girlParam[p])
	for p in params :
		print("param: ",p)
	for i in layerList :
		var filter = true
		for j in i["tags"] :
#			if (params.find( str(j)) == -1) :
			if !(j in params) :
#				print("Didn't find ",j," in ",i["path"])
				filter = false
				break
		if (filter == true) :
			print("Found ",i["path"])
			filtList.append( i)
	printlayerList( filtList)
	for l in filtList :
		var spr = Sprite.new()
		spr.set_name( l["path"])
		spr.set_centered(false)
		spr.set_offset(Vector2(108.5,0))
		spr.set_texture( loadRes( l["path"]))
		spr.set_z( int( l["depth"]))
		ref.add_child( spr)
	pass

func printParams() :
	for i in girlParam :
		print( "Selected girl params: ",girlParam[i])
	pass

func printlayerList( list) :
	for i in list :
		libs.logd( str("MSG: layer path: ",i["path"]))
		libs.logd( str("MSG: layer depth: ",i["depth"]))
		for j in i["tags"] :
			libs.logd( str("MSG: tag: ",j))
	pass

func filtTag () :
	pass


func _on_gen_pressed():
	genImage()
	pass # replace with function body
