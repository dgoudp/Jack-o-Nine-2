####	Slave girl class
#
#		this script contains all relevant data on slave
#		the term "girl" is used to confuse with "slaver"
#


extends Node

#		subclass to deal with common used min max range in context
class Val :
	var value = 0
	var minvalue = 0
	var maxvalue = 1
	
	func _init(nmin = 0.0, nmax = 1.0):
		if nmin < nmax :
			minvalue = nmin
			maxvalue = nmax
	
	func set_minmax(nmin, nmax):
		if nmin < nmax :
			minvalue = nmin
			maxvalue = nmax
	
	func set_value(newvalue):
		value = clamp(newvalue,minvalue,maxvalue)
		
	func add_value(addvalue):
		addvalue += value
		value = clamp(addvalue,minvalue,maxvalue)
		
	func rand_value(nmin = minvalue, nmax = maxvalue):
		nmax = min(maxvalue, nmax)
		nmin = max(minvalue, nmin)
		value = rand_range(nmin,nmax)

#		all data pertaining to slave girl
#		they're group in categories
#		associated list are only for key reference and auto initialization
var name = "girl_machine_name"
var namefull = "Human Name"

#		common daily stats
var stats = {
	"mood" : Val.new(-5.0,5.0),
	"stamina" : Val.new(0,5),
	"wound" : Val.new(0,5),
	"disease" : Val.new(0,5),
	"ovulation" : Val.new(0,10),
	"pregnancy" : Val.new(0,10)
	}

#		traits defined at creation or gained
#		affects other stats and skill gain
var traits = {
	"maid" : false,
	"secretary" : false,
	"sorceress" : false,
	"athlete" : false,
	"artist" : false,
	}

#		regular body stats
#		some stats and one time application
var body = {
	"bust" : Val.new(0,4),
	"hip" : Val.new(0,3),
	"vagina" : Val.new(-3.0,3.0),
	"anus" : Val.new(-3.0,3.0),
	"tattoo" : Val.new(0,2),
	"facetatto" : false,
	"piercenipple" : false,
	"piercevagina" : false,
	"piercenavel" : false,
	"modbust" : false,
	"modplastic" : false
	}

#		basic attributes
#		ranging from F=0 to S=5
var attribute = {
	"beauty" : Val.new(0.0,5.5),
	"endurance" : Val.new(0.0,5.5),
	"empathy" : Val.new(0.0,5.5),
	"nature" : Val.new(0.0,5.5),
	"pride" : Val.new(0.0,5.5),
	"intellect" : Val.new(0.0,5.5),
	"physique" : Val.new(0.0,5.5),
	"exotic" : Val.new(0.0,5.5),
	"fame" : Val.new(0.0,5.5)
	}

#		data of psychological stats
#		each with a rate range that when reach trigger a level change
var psych = {
	"fat" : Val.new(-5,5),
	"fatrate" : Val.new (-20.0,20.0),
	"obedience" : Val.new(-5,5),
	"obediencerate" : Val.new (-20.0,20.0),
	"fear" : Val.new(-5,5),
	"fearrate" : Val.new (-20.0,20.0),
	"despair" : Val.new(-5,5),
	"despairrate" : Val.new (-20.0,20.0),
	"arousal" : Val.new(-5,5),
	"arousalrate" : Val.new (-20.0,20.0)
	}

#		common skills
#		range from none=0, to S=6
var skillcom = {
	"maid" : Val.new(0.0,6.0),
	"cook" : Val.new(0.0,6.0),
	"secretary" : Val.new(0.0,6.0),
	"escort" : Val.new(0.0,6.0),
	"nurse" : Val.new(0.0,6.0),
	"chemist" : Val.new(0.0,6.0),
	"gladiatrix" : Val.new(0.0,6.0),
	"dancer" : Val.new(0.0,6.0),
	"singer" : Val.new(0.0,6.0),
	"musician" : Val.new(0.0,6.0)
	}

#		sexual skills
#		grouped into categories
#		parent grade is equal to avarage
var skillsex = {
	"petting" : {
		"handjob" : Val.new(0.0,5.0),
		"titjob" : Val.new(0.0,5.0),
		"massage" : Val.new(0.0,5.0)
		},
	"oral" : {
		"kissing" : Val.new(0.0,5.0),
		"blowjob" : Val.new(0.0,5.0),
		"rimming" : Val.new(0.0,5.0)
		},
	"penetration" : {
		"vagsex" : Val.new(0.0,5.0),
		"analsex" : Val.new(0.0,5.0),
		"fisting" : Val.new(0.0,5.0)
		},
	"group" : {
		"threesome" : Val.new(0.0,5.0),
		"doublesex" : Val.new(0.0,5.0),
		"gangbang" : Val.new(0.0,5.0)
		},
	"demonstration" : {
		"seduction" : Val.new(0.0,5.0),
		"masturbation" : Val.new(0.0,5.0),
		"exhibitionism" : Val.new(0.0,5.0)
		},
	"fetish" : {
		"masochism" : Val.new(0.0,5.0),
		"dominatrix" : Val.new(0.0,5.0),
		"torture" : Val.new(0.0,5.0)
		}
	}


func _init():
	pass
