PlayVNDemo = {}
class("PlayVNDemo").extends(NobleScene)

import "CoreLibs/nineslice"

PlayVNDemo.baseColor = Graphics.kColorBlack

local background
local sequence
local kTransition
kTransition = "yes"

gridview = playdate.ui.gridview.new(0,32)
-- newfont = Graphics.font.new("oldsource/fonts/REPLACETHISPART")

import 'libraries/playvn/visualnovelfunctions'
import 'libraries/playvn/customfunctions'

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function PlayVNDemo:init()
	PlayVNDemo.super.init(self)
	thisscenename = 'PlayVNDemo'
	background = Graphics.image.new("assets/images/basic_room")
	db1 = playdate.datastore.read("assets/json/PlayVNDemo")
	db = db1[1]
	if (line == nil) then
		line = deepcopy(db["title1"])
	else
		line = deepcopy(db[line["goto"]])
	end
	isinmenu = "no"
	cursoractive = "no"
	cursorX = "200"
	cursorY = "140"
	cursor = Graphics.image.new("assets/images/cursor15")
	cursoron = Graphics.image.new("assets/images/cursor15on")
	if vnvariables==nil then vnvariables = {} end
end

function PlayVNDemo:enter()
	dialogueEvent()
end

function PlayVNDemo:start()
	PlayVNDemo.super.start(self)
	kTransition = "no"
end

function PlayVNDemo:drawBackground()
	PlayVNDemo.super.drawBackground(self)
	background:draw(0, 0)
end

function PlayVNDemo:update()
	if autoadvancelimit~=nil then
		if autoadvancecounter == autoadvancelimit then
			dialogueEvent()
		else
			autoadvancecounter = autoadvancecounter + 1
		end
	end
	PlayVNDemo.super.update(self)
	if(kTransition == "no") then
		if cursoractive == "yes" then
			cursorMover()
		end
		if isinmenu == "no" then
		        checkEventType()
		else
			checkMenuStuff()
		end
	end
	doAnimations()
	Graphics.sprite.update()
	playdate.timer.updateTimers()
end

function PlayVNDemo:exit()
	PlayVNDemo.super.exit(self)
	kTransition = "yes"
	Noble.Input.setCrankIndicatorStatus(false)
	sequence = Sequence.new():from(100):to(240, 0.25, Ease.inSine)
	sequence:start();
end

function PlayVNDemo:finish()
	PlayVNDemo.super.finish(self)
end
