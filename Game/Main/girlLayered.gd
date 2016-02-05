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

func _ready():
	libs.logd("MSG: girlLayered test scene",true)
	layerList = libs.loadJsonMult(str(prepath,"info.json"))
	if layerList == null :
		libs.logd("ERR: layerList null")
#		get_tree().quit()
	else :
		libs.logd("MSG: girlTaglist loaded, attempt loading of images")
		call_deferred("initParamList")
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
	girlParList["Npc"] = ["NpcA","NpcB"] 
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
	girlParList["Expression"] = ["Expression01","Expression02","Expression03","Expression04","Expression05","Expression06","Expression07","Expression08","Expression09","Expression10","Expression11"] 
	girlParam["Expression"] = girlParList["Expression"][get_node("selpanel/center/vbox/hbox/options/Expression").get_selected()]
	

func genImage () :
	var ref = get_node("ReferenceFrame")
	while (ref.get_child_count() > 0) :
		ref.get_child(0).free()
	var params = []
	var filtList = []
	for p in girlParam :
		params.append(girlParam[p])
	for i in layerList :
		var filter = true
		for j in layerList[i]["tags"] :
			if (params.find(layerList[i]["tags"][j]) == -1) :
				filter = false
		if (filter == true) :
			filtList.append( layerList[i])
	for l in filtList :
		var spr = Sprite.new()
		spr.set_name( filtList[l]["path"])
		spr.set_centered(false)
		spr.set_offset(Vector2(108.5,0))
		spr.set_texture( loadRes(str(prepath, filtList[l]["path"])))
		spr.set_z( filtList[l]["depth"])
	pass
	
func filtTag () :
	pass


func _on_gen_pressed():
	genImage()
	pass # replace with function body
