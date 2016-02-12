####	Layer girl panel
#
#		simple panel to test the build of layered girls
#

extends Node

var libs = preload("res://Game/Main/libs.gd")

export(String, DIR) var prepath = "res://Girls/setCRV/"

var layerList = []		# array with all info loaded
var definitions = {}
#var girlParList = {}	# reference for parameters id
var girlParam = []		# actually selected parameters

var resBank = ResourcePreloader.new()

func _enter_tree():
	libs.logd("MSG: girlLayered test scene",true)
	definitions = libs.loadJson( str(prepath,"definitions.json"))
	layerList = libs.loadJsonMult( str(prepath,"OV001/metadata.json"))
	pass

func _ready():
	if layerList == null :
		libs.logd("ERR: layerList null")
	else :
		libs.logd("MSG: girlTaglist loaded, attempt loading of images")
		genMenu()
		get_node("selpanel/center/vbox/gen").connect("pressed",self,"_on_gen_pressed",[],1)
		get_node("selpanel/quit").connect("pressed",self,"_on_quit_pressed",[],1)
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

#func initParamList() :
	#	Basic parameters
#	girlParam["back"] = ["background"]
#	girlParam["body"] = ["body"]
#	girlParam["head"] = ["head"]
#	girlParam["Col"] = ["ColA"]
	#	Attributed parameters
#	girlParList["Skn"] = ["SknA","SknB","SknC","SknD"] 
#	girlParam["Skn"] = girlParList["Skn"][get_node("selpanel/center/vbox/hbox/options/Skn").get_selected()]
#	girlParList["Bst"] = ["BstA","BstB","BstC","BstD"] 
#	girlParam["Bst"] = girlParList["Bst"][get_node("selpanel/center/vbox/hbox/options/Bst").get_selected()]
#	girlParList["Nip"] = ["NipA","NipB"] 
#	girlParam["Nip"] = girlParList["Nip"][get_node("selpanel/center/vbox/hbox/options/Nip").get_selected()]
#	girlParList["Npc"] = ["NpCA","NpCB"] 
#	girlParam["Npc"] = girlParList["Npc"][get_node("selpanel/center/vbox/hbox/options/Npc").get_selected()]
#	girlParList["Hrb"] = ["none","HrbA","HrbB","HrbC","HrbD","HrbE","HrbF","HrbE","HrbG"] 
#	girlParam["Hrb"] = girlParList["Hrb"][get_node("selpanel/center/vbox/hbox/options/Hrb").get_selected()]
#	girlParList["Hrs"] = ["none","HrsA"] 
#	girlParam["Hrs"] = girlParList["Hrs"][get_node("selpanel/center/vbox/hbox/options/Hrs").get_selected()]
#	girlParList["Hrf"] = ["none","HrfA","HrfB","HrfC","HrfD","HrfE","HrfF","HrfE","HrfG"] 
#	girlParam["Hrf"] = girlParList["Hrf"][get_node("selpanel/center/vbox/hbox/options/Hrf").get_selected()]
#	girlParList["Eye"] = ["EyeA","EyeB"] 
#	girlParam["Eye"] = girlParList["Eye"][get_node("selpanel/center/vbox/hbox/options/Eye").get_selected()]
#	girlParList["Eyb"] = ["EybA","EybB"] 
#	girlParam["Eyb"] = girlParList["Eyb"][get_node("selpanel/center/vbox/hbox/options/Eyb").get_selected()]
#	girlParList["Expression"] = ["expression01","expression02","expression03","expression04","expression05","expression06","expression07","expression08","expression09","expression10","expression11"] 
#	girlParam["Expression"] = girlParList["Expression"][get_node("selpanel/center/vbox/hbox/options/Expression").get_selected()]

#		generate menu
func genMenu() :
	var labels = get_node("selpanel/center/vbox/hbox/labels")
	while (labels.get_child_count() > 0) :
		labels.get_child(0).free()
	var options = get_node("selpanel/center/vbox/hbox/options")
	while (options.get_child_count() > 0) :
		options.get_child(0).free()
	for i in range( definitions["paramList"].size() ) :
		var param = definitions["paramList"][i]
#		create label
		var lab = Label.new()
		lab.set_name(param)
		lab.set_text(param)
		lab.set_h_size_flags(1)
		lab.set_v_size_flags(1)
#		create option button
		var but = OptionButton.new()
		but.set_name(param)
		but.set_h_size_flags(3)
		but.set_v_size_flags(2)
		for item in definitions["paramOption"][param] :
			but.add_item(item)
#			possibility of adding custom signals

#		for item in range( definitions["parameters"][param].size):
#			but.add_item(definitions["parameters"][param][item],item)
#		add them to scene
		but.connect("item_selected",self,"_on_option_changed",[],1)
		labels.add_child(lab)
		options.add_child(but)

#		get selected params
func getParams () :
	girlParam.clear()
#	add common params
	var com = []
	for i in range ( definitions["paramPre"].size()) :
		girlParam.append( definitions["paramPre"][i])
	for i in range ( definitions["paramList"].size()) :
		var param = definitions["paramList"][i]
		var but = get_node("selpanel/center/vbox/hbox/options").find_node(param,true,false)
		var idx = but.get_selected()
		var tag = definitions["paramOption"][param][idx]
		if (girlParam.find( tag) == -1) :
			girlParam.append( tag)
			libs.logd( str("MSG: added filter tag: ", tag ))



func genImage() :
	var frame = get_node("ReferenceFrame")
	var filtList = []
#		begin madness
#	for p in params :
#		libs.logd( str("MSG: Param item: ",p))
	while (frame.get_child_count() > 0) :
		frame.get_child(0).free()
	getParams()
	for layer in layerList :
		var filter = true
		for tag in layer["tags"] :
			if ( girlParam.find( tag) == -1) :
				filter = false
#			if not tag in params :
#				libs.logd( str("MSG: check fail: ",layer["path"]," tag: ",tag))
#				filter = false
#			else :
#				libs.logd( str("MSG: check pass: ",layer["path"]," tag: ",tag))
		# now add to filtered list
		if filter :
			libs.logd( str("MSG: Added layer to filtList: ",layer["path"]))
			filtList.append(layer)
	for layer in filtList :
		var spr = Sprite.new()
		spr.set_name( layer["path"])
		spr.set_centered(true)
		spr.set_pos( Vector2(417,400))
		spr.set_scale( Vector2(0.816,0.816))
		spr.set_offset(Vector2(0,0))
		spr.set_texture( loadRes( str("OV001/",layer["path"])))
		spr.set_z( int( layer["depth"]))
		frame.add_child( spr)



#
#
#func genImage () :
#	var ref = get_node("ReferenceFrame")
#	while (ref.get_child_count() > 0) :
#		ref.get_child(0).free()
#	printParams()
#	var params = []
#	var filtList = []
#	for p in girlParam :
#		params.append(girlParam[p])
#		print("Param added: ",girlParam[p])
#	for p in params :
#		print("param: ",p)
#	for i in layerList :
#		var filter = true
#		for j in i["tags"] :
#			if (params.find( str(j)) == -1) :
#			if !(j in params) :
#				print("Didn't find ",j," in ",i["path"])
#				filter = false
#				break
#		if (filter == true) :
#			print("Found ",i["path"])
#			filtList.append( i)
#	printlayerList( filtList)
#	for l in filtList :
#		var spr = Sprite.new()
#		spr.set_name( l["path"])
#		spr.set_centered(false)
#		spr.set_offset(Vector2(108.5,0))
#		spr.set_texture( loadRes( l["path"]))
#		spr.set_z( int( l["depth"]))
#		ref.add_child( spr)
#	pass

#func printParams() :
#	for i in girlParam :
#		print( "Selected girl params: ",girlParam[i])
#	pass

#func printlayerList( list) :
#	for i in list :
#		libs.logd( str("MSG: layer path: ",i["path"]))
#		libs.logd( str("MSG: layer depth: ",i["depth"]))
#		for j in i["tags"] :
#			libs.logd( str("MSG: tag: ",j))
#	pass


func _on_gen_pressed():
	genImage()

func _on_option_changed( idx):
	genImage()

func _on_quit_pressed():
	get_tree().quit()
