import 'libraries/noble/Noble'

import 'utilities/Utilities'

import 'scenes/PlayVNDemo'

Noble.GameData.setup(
	{
		gdbackground = "",
		gdleftpeep = "",
		gdmiddlepeep = "",
		gdrightpeep = "",
		gdwhichpeep = "",
		gdleftpeepflip = "",
		gdmiddlepeepflip = "",
		gdrightpeepflip = "",
		gdbgm = "",
		gdbgmidi = "",
		gdsfx = "",
		gdline = "1",
		gdvariables = "",
		gdoverlay = "",
		ldbackground = "",
		ldleftpeep = "",
		ldmiddlepeep = "",
		ldrightpeep = "",
		ldwhichpeep = "",
		ldleftpeepflip = "",
		ldmiddlepeepflip = "",
		ldrightpeepflip = "",
		ldbgm = "",
		ldbgmidi = "",
		ldsfx = "",
		ldline = "1",
		ldvariables = "",
		ldoverlay = ""
	},
	1,
	true,
	true
)

leftpeepoffset = 100		
middlepeepoffset = 200		
rightpeepoffset = 300
pressastate = 1
savetemp = {}

Noble.showFPS = false

Noble.new(PlayVNDemo, 1.5, Noble.Transition.CrossDissolve)
