local snd = playdate.sound
local gfx = playdate.graphics

function mysplit(inputstr, sep)
	if sep == nil then
	   sep = "%s"
	end
	local t={}
	local counta=1
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
	   t[counta] = str
	   counta = counta +1
	end
	return t
end

function replace_char(pos, str, r)
    return str:sub(1, pos-1) .. r .. str:sub(pos+1)
end

function createTextbox()
	if textbox ~= nil then textbox:remove() end
	if (line["content"]~=nil)then
		textbox = Graphics.sprite.new()
		textbox:setSize(400, 60)
		textbox:setCenter(0,0)
		textbox:moveTo(0, 190)
		textbox:setZIndex(998)
		textbox.text = ""
		textbox.currentChar = 1
		textbox.currentText = ""
		textbox.typing = true

		function textbox:update()
			self.currentChar = self.currentChar + 1
			if self.currentChar > #self.text then
				self.currentChar = #self.text
			end
			if self.typing and self.currentChar <= #self.text then
				textbox.currentText = string.sub(self.text, 1, self.currentChar)
				self:markDirty()
			end
			if self.currentChar == #self.text then
				self.currentChar = 1
				self.typing = false
			end	
		end

		function textbox:draw()
			Graphics.pushContext()
				Graphics.setColor(Graphics.kColorWhite)
				Graphics.fillRect(0,0,400,60)
				Graphics.setLineWidth(4)
				Graphics.setColor(Graphics.kColorBlack)
				Graphics.drawRect(0,0,400,60)
				Graphics.drawTextInRect(self.currentText, 10, 10, 380, 40)
			Graphics.popContext()
		end

		local linecheckedtext = line["content"]
		if(Graphics.getTextSize(linecheckedtext)>=372)then
			local foundspace = 0
			local previousspace = nil
			while true do
   				foundspace = linecheckedtext:find(" ", foundspace+1)
   				if foundspace==nil then
					if(previousspace~=nil) then
						linecheckedtext = replace_char(previousspace, linecheckedtext, "\n")
						break
					end
					break
				end
   				if(Graphics.getTextSize(string.sub(linecheckedtext,0,foundspace))>=372)then
					if(previousspace~=nil) then
						linecheckedtext = replace_char(previousspace, linecheckedtext, "\n")
						break
					end
				end
				previousspace = foundspace
			end
		end
		textbox.text = linecheckedtext
		textbox:add()
	end
	if whobox ~= nil then whobox:remove() end
	if line["whospeaking"]~=nil then
		local whoboxlen = Graphics.getTextSize(line["whospeaking"]) + 10
		whobox = Graphics.sprite.new()
		whobox:setSize(whoboxlen, 26)
		whobox:setCenter(0,0)
		whobox:moveTo(4, 170)
		whobox:setZIndex(999)
		whobox.text = ""
		whobox.currentText = line["whospeaking"]
		
		function whobox:draw()
			Graphics.pushContext()		
				Graphics.setColor(Graphics.kColorWhite)
				Graphics.fillRoundRect(0,0,whoboxlen,26,4)
				Graphics.setLineWidth(1)
				Graphics.setColor(Graphics.kColorBlack)
				Graphics.drawRoundRect(0,0,whoboxlen,26,4)
				Graphics.drawTextInRect(self.currentText, 4, 4, whoboxlen, 20)
			Graphics.popContext()
		end
		whobox.text = line["whospeaking"]
		whobox:add()
	end
	saveData("gdline", line["goto"])
	line = deepcopy(db[line["goto"]])
end


function createDialogueMenu()
	isinmenu = "yes"
	lineoptions = mysplit(line["goto"],"|")
	contentoptions = mysplit(line["content"],"|")
	contentgridheight = #contentoptions * 36 + 10
	gridview:setNumberOfRows(#contentoptions)
	gridview:setCellPadding(2, 2, 2, 2)
	
	gridview.backgroundImage = Graphics.nineSlice.new("assets/images/textbox", 4, 4, 1, 1)
	gridview:setContentInset(5, 5, 5, 5)
	gridview:setSelectedRow(1)
	gridviewSprite = Graphics.sprite.new()
	gridviewSprite:setCenter(0, 0)
	gridviewSprite:moveTo(50, 20)
	gridviewSprite:setZIndex(999)
	gridviewSprite:add()
end


function gridview:drawCell(section, row, column, selected, x, y, width, height)
    if selected then
        Graphics.fillRoundRect(x, y, width, height, 4)
        Graphics.setImageDrawMode(Graphics.kDrawModeFillWhite)
    else
        Graphics.setImageDrawMode(Graphics.kDrawModeCopy)
    end
    local fontHeight = Graphics.getSystemFont():getHeight()
    Graphics.drawTextInRect(contentoptions[row], x, y + (height/2 - fontHeight/2) + 2, width, height, nil, nil, kTextAlignment.center)
end


function doAnimations()
	if splitbackground~=nil then
		if backgroundSprite ~= nil then backgroundSprite:remove() end
		currentbackground = mysplit(splitbackground[splitbackgroundcount],":")
		if (tonumber(currentbackground[2]) < splitbackgroundframe and currentbackground[2]~="0") then
			splitbackgroundcount = splitbackgroundcount + 1
			splitbackgroundframe = 1
			if splitbackground[splitbackgroundcount]==nil then splitbackgroundcount = 1 end
			currentbackground = mysplit(splitbackground[splitbackgroundcount],":")
		end
		background = Graphics.image.new("assets/images/" .. currentbackground[1])
		backgroundSprite = Graphics.sprite.new(background)
		backgroundSprite:setCenter(0.5, 0)
		backgroundSprite:moveTo(200, 0)
		backgroundSprite:add()
		splitbackgroundframe = splitbackgroundframe + 1
	end
	if splitoverlay~=nil then
		if overlaySprite ~= nil then overlaySprite:remove() end
		currentoverlay = mysplit(splitoverlay[splitoverlaycount],":")
		if (tonumber(currentoverlay[4]) < splitoverlayframe and currentoverlay[4]~="0") then
			splitoverlaycount = splitoverlaycount + 1
			splitoverlayframe = 1
			if splitoverlay[splitoverlaycount]==nil then splitoverlaycount = 1 end
			currentoverlay = mysplit(splitoverlay[splitoverlaycount],":")
		end
		overlay = Graphics.image.new("assets/images/" .. currentoverlay[1])
		overlaySprite = Graphics.sprite.new(overlay)
		overlaySprite:setCenter(0, 0)
		overlaySprite:moveTo(currentoverlay[2], currentoverlay[3])
		overlaySprite:setZIndex(997)
		overlaySprite:add()
		splitoverlayframe = splitoverlayframe + 1
	end
	if splitleftpeep~=nil then
		if leftpeepSprite ~= nil then leftpeepSprite:remove() end
		if textbox~=nil and textbox.typing and splitleftpeeptalking~=nil then
			currentleftpeep = mysplit(splitleftpeeptalking[splitleftpeeptalkingcount],":")
			if (tonumber(currentleftpeep[2]) < splitleftpeeptalkingframe and currentleftpeep[2]~="0") then
				splitleftpeeptalkingcount = splitleftpeeptalkingcount + 1
				splitleftpeeptalkingframe = 1
				if splitleftpeeptalking[splitleftpeeptalkingcount]==nil then splitleftpeeptalkingcount = 1 end
				currentleftpeep = mysplit(splitleftpeeptalking[splitleftpeeptalkingcount],":")
			end
			leftpeep = Graphics.image.new("assets/images/" .. currentleftpeep[1])
			leftpeepSprite = Graphics.sprite.new(leftpeep)
			leftpeepSprite:setCenter(0.5, 0)
			leftpeepSprite:moveTo(leftpeepoffset, 0)
			leftpeepSprite:add()
			splitleftpeeptalkingframe = splitleftpeeptalkingframe + 1
		else
			currentleftpeep = mysplit(splitleftpeep[splitleftpeepcount],":")
			if (tonumber(currentleftpeep[2]) < splitleftpeepframe and currentleftpeep[2]~="0") then
				splitleftpeepcount = splitleftpeepcount + 1
				splitleftpeepframe = 1
				if splitleftpeep[splitleftpeepcount]==nil then splitleftpeepcount = 1 end
				currentleftpeep = mysplit(splitleftpeep[splitleftpeepcount],":")
			end
			leftpeep = Graphics.image.new("assets/images/" .. currentleftpeep[1])
			leftpeepSprite = Graphics.sprite.new(leftpeep)
			leftpeepSprite:setCenter(0.5, 0)
			leftpeepSprite:moveTo(leftpeepoffset, 0)
			leftpeepSprite:add()
			splitleftpeepframe = splitleftpeepframe + 1
		end
	end
	if splitmiddlepeep~=nil then
		if middlepeepSprite ~= nil then middlepeepSprite:remove() end
		if textbox~=nil and textbox.typing and splitmiddlepeeptalking~=nil then
			currentmiddlepeep = mysplit(splitmiddlepeeptalking[splitmiddlepeeptalkingcount],":")
			if (tonumber(currentmiddlepeep[2]) < splitmiddlepeeptalkingframe and currentmiddlepeep[2]~="0") then
				splitmiddlepeeptalkingcount = splitmiddlepeeptalkingcount + 1
				splitmiddlepeeptalkingframe = 1
				if splitmiddlepeeptalking[splitmiddlepeeptalkingcount]==nil then splitmiddlepeeptalkingcount = 1 end
				currentmiddlepeep = mysplit(splitmiddlepeeptalking[splitmiddlepeeptalkingcount],":")
			end
			middlepeep = Graphics.image.new("assets/images/" .. currentmiddlepeep[1])
			middlepeepSprite = Graphics.sprite.new(middlepeep)
			middlepeepSprite:setCenter(0.5, 0)
			middlepeepSprite:moveTo(middlepeepoffset, 0)
			middlepeepSprite:add()
			splitmiddlepeeptalkingframe = splitmiddlepeeptalkingframe + 1
		else
			currentmiddlepeep = mysplit(splitmiddlepeep[splitmiddlepeepcount],":")
			if (tonumber(currentmiddlepeep[2]) < splitmiddlepeepframe and currentmiddlepeep[2]~="0") then
				splitmiddlepeepcount = splitmiddlepeepcount + 1
				splitmiddlepeepframe = 1
				if splitmiddlepeep[splitmiddlepeepcount]==nil then splitmiddlepeepcount = 1 end
				currentmiddlepeep = mysplit(splitmiddlepeep[splitmiddlepeepcount],":")
			end
			middlepeep = Graphics.image.new("assets/images/" .. currentmiddlepeep[1])
			middlepeepSprite = Graphics.sprite.new(middlepeep)
			middlepeepSprite:setCenter(0.5, 0)
			middlepeepSprite:moveTo(middlepeepoffset, 0)
			middlepeepSprite:add()
			splitmiddlepeepframe = splitmiddlepeepframe + 1
		end
	end
	if splitrightpeep~=nil then
		if rightpeepSprite ~= nil then rightpeepSprite:remove() end
		if textbox~=nil and textbox.typing and splitrightpeeptalking~=nil then
			currentrightpeep = mysplit(splitrightpeeptalking[splitrightpeeptalkingcount],":")
			if (tonumber(currentrightpeep[2]) < splitrightpeeptalkingframe and currentrightpeep[2]~="0")then
				splitrightpeeptalkingcount = splitrightpeeptalkingcount + 1
				splitrightpeeptalkingframe = 1
				if splitrightpeeptalking[splitrightpeeptalkingcount]==nil then splitrightpeeptalkingcount = 1 end
				currentrightpeep = mysplit(splitrightpeeptalking[splitrightpeeptalkingcount],":")
			end
			rightpeep = Graphics.image.new("assets/images/" .. currentrightpeep[1])
			rightpeepSprite = Graphics.sprite.new(rightpeep)
			rightpeepSprite:setCenter(0.5, 0)
			rightpeepSprite:moveTo(rightpeepoffset, 0)
			rightpeepSprite:add()
			splitrightpeeptalkingframe = splitrightpeeptalkingframe + 1
		else
			currentrightpeep = mysplit(splitrightpeep[splitrightpeepcount],":")
			if (tonumber(currentrightpeep[2]) < splitrightpeepframe and currentrightpeep[2]~="0") then
				splitrightpeepcount = splitrightpeepcount + 1
				splitrightpeepframe = 1
				if splitrightpeep[splitrightpeepcount]==nil then splitrightpeepcount = 1 end
				currentrightpeep = mysplit(splitrightpeep[splitrightpeepcount],":")
			end
			rightpeep = Graphics.image.new("assets/images/" .. currentrightpeep[1])
			rightpeepSprite = Graphics.sprite.new(rightpeep)
			rightpeepSprite:setCenter(0.5, 0)
			rightpeepSprite:moveTo(rightpeepoffset, 0)
			rightpeepSprite:add()
			splitrightpeepframe = splitrightpeepframe + 1
		end
	end
	local getwhichpeep = Noble.GameData.get("gdwhichpeep")
	if getwhichpeep == "left" then
		if leftpeepSprite~=nil then leftpeepSprite:moveTo(leftpeepoffset,-10) end
	elseif getwhichpeep == "middle" then
		if middlepeepSprite~=nil then middlepeepSprite:moveTo(middlepeepoffset,-10) end
	elseif getwhichpeep == "right" then
		if rightpeepSprite~=nil then rightpeepSprite:moveTo(rightpeepoffset,-10) end
	end
	if(Noble.GameData.get("gdleftpeepflip")~=nil and Noble.GameData.get("gdleftpeepflip")~="") then
		if leftpeepSprite~=nil then leftpeepSprite:setImageFlip("flipX") end
	end
	if(Noble.GameData.get("gdmiddlepeepflip")~=nil and Noble.GameData.get("gdmiddlepeepflip")~="") then
		if middlepeepSprite~=nil then middlepeepSprite:setImageFlip("flipX") end
	end
	if(Noble.GameData.get("gdrightpeepflip")~=nil and Noble.GameData.get("gdrightpeepflip")~="") then
		if rightpeepSprite~=nil then rightpeepSprite:setImageFlip("flipX") end
	end
end

function changeScene()
	local thisduration = "1.5"
	if line["duration"]~=nil then
		thisduration = line["duration"]
	end
	print(thisscenename)
	if(line["newscene"]~=nil) then
		print('new scene')
		PVNtoscene = line["newscene"]
	else
		print('same scene')
		PVNtoscene = thisscenename
	end
	print(PVNtoscene)
	if line["transition"] == "CUT" then
		Noble.transition(_G[PVNtoscene], thisduration, Noble.TransitionType.CUT)
	elseif line["transition"] == "CROSS_DISSOLVE" then
		Noble.transition(_G[PVNtoscene], thisduration, Noble.TransitionType.CROSS_DISSOLVE)
	elseif line["transition"] == "DIP_TO_WHITE" then
		Noble.transition(_G[PVNtoscene], thisduration, Noble.TransitionType.DIP_TO_WHITE)
	elseif line["transition"] == "DIP_WIDGET_SATCHEL" then
		Noble.transition(_G[PVNtoscene], thisduration, Noble.TransitionType.DIP_WIDGET_SATCHEL)
	elseif line["transition"] == "DIP_METRO_NEXUS" then
		Noble.transition(_G[PVNtoscene], thisduration, Noble.TransitionType.DIP_METRO_NEXUS)
	elseif line["transition"] == "SLIDE_OFF_LEFT" then
		Noble.transition(_G[PVNtoscene], thisduration, Noble.TransitionType.SLIDE_OFF_LEFT)
	elseif line["transition"] == "SLIDE_OFF_RIGHT" then
		Noble.transition(_G[PVNtoscene], thisduration, Noble.TransitionType.SLIDE_OFF_RIGHT)
	elseif line["transition"] == "SLIDE_OFF_UP" then
		Noble.transition(_G[PVNtoscene], thisduration, Noble.TransitionType.SLIDE_OFF_UP)
	elseif line["transition"] == "SLIDE_OFF_DOWN" then
		Noble.transition(_G[PVNtoscene], thisduration, Noble.TransitionType.SLIDE_OFF_DOWN)
	else
		Noble.transition(_G[PVNtoscene], thisduration, Noble.TransitionType.DIP_TO_BLACK)
	end
	print("it wasn't that bit")
end


function dbBackgroundCheck(nosave)
    if line["background"]~=nil then
		if nosave~="nosave" then saveData("gdbackground", line["background"]) end
		if backgroundSprite~=nil then backgroundSprite:remove() end
		splitbackground=nil
		if string.find(line["background"],":") then
			splitbackground = mysplit(line["background"],"|")
			splitbackgroundcount = 1
			splitbackgroundframe = 1
			splitfirstbackground = mysplit(splitbackground[1],":")
			background = Graphics.image.new("assets/images/" .. splitfirstbackground[1])
			backgroundSprite = Graphics.sprite.new(background)
		else
			background = Graphics.image.new("assets/images/" .. line["background"])
			backgroundSprite = Graphics.sprite.new(background)
		end
		backgroundSprite:setCenter(0, 0)
		backgroundSprite:moveTo(0, 0)
		backgroundSprite:add()
    end
end


function clearPeeps()
	print("clearing peeps")
	saveData("gdleftpeep", "")
	saveData("gdmiddlepeep", "")
	saveData("gdrightpeep", "")
	if leftpeepSprite~=nil then 
		print("clearing left peep")
		leftpeepSprite:remove()	
	end
	if middlepeepSprite~=nil then 
		print("clearing middle peep")
		middlepeepSprite:remove()	
	end
	if rightpeepSprite~=nil then 
		print("clearing right peep")
		rightpeepSprite:remove() 
	end
end


function clearDialogue()
	if textbox ~= nil then textbox:remove() end
	if whobox ~= nil then whobox:remove() end
end


function checkPeeps()
	if line["leftpeepoffset"]~=nil then
		leftpeepoffset = line["leftpeepoffset"]
	end
	if line["middlepeepoffset"]~=nil then
		middlepeepoffset = line["middlepeepoffset"]
	end
	if line["rightpeepoffset"]~=nil then
		rightpeepoffset = line["rightpeepoffset"]
	end
	if line["leftpeep"]~=nil then
		splitleftpeep=nil
		saveData("gdleftpeep", line["leftpeep"])
		if line["leftpeep"]=="" then
			if leftpeepSprite ~= nil then leftpeepSprite:remove() end
		else
			if leftpeepSprite ~= nil then leftpeepSprite:remove() end
			if string.find(line["leftpeep"],":") then
				splitleftpeep = mysplit(line["leftpeep"],"|")
				splitleftpeepcount = 1
				splitleftpeepframe = 1
				splitfirstleftpeep = mysplit(splitleftpeep[1],":")
				leftpeep = Graphics.image.new("assets/images/" .. splitfirstleftpeep[1])
				leftpeepSprite = Graphics.sprite.new(leftpeep)
			else
				leftpeep = Graphics.image.new("assets/images/" .. line["leftpeep"])
				leftpeepSprite = Graphics.sprite.new(leftpeep)
			end
			leftpeepSprite:setCenter(0, 0)
			leftpeepSprite:moveTo(0, 0)
			leftpeepSprite:add()
		end
	end
	if line["middlepeep"]~=nil then
		saveData("gdmiddlepeep", line["middlepeep"])
		splitmiddlepeep=nil
		if line["middlepeep"]=="" then
			if middlepeepSprite ~= nil then middlepeepSprite:remove() end
		else
			if middlepeepSprite ~= nil then middlepeepSprite:remove() end
			if string.find(line["middlepeep"],":") then
				splitmiddlepeep = mysplit(line["middlepeep"],"|")
				splitmiddlepeepcount = 1
				splitmiddlepeepframe = 1
				splitfirstmiddlepeep = mysplit(splitmiddlepeep[1],":")
				middlepeep = Graphics.image.new("assets/images/" .. splitfirstmiddlepeep[1])
				middlepeepSprite = Graphics.sprite.new(middlepeep)
			else
				middlepeep = Graphics.image.new("assets/images/" .. line["middlepeep"])
				middlepeepSprite = Graphics.sprite.new(middlepeep)
			end
			middlepeepSprite:setCenter(0.5, 0)
			middlepeepSprite:moveTo(200, 0)
			middlepeepSprite:add()
		end
	end
	if line["rightpeep"]~=nil then
		saveData("gdrightpeep", line["rightpeep"])
		splitrightpeep=nil
		if line["rightpeep"]=="" then
			if rightpeepSprite ~= nil then rightpeepSprite:remove() end
		else
			if rightpeepSprite ~= nil then rightpeepSprite:remove() end
			if string.find(line["rightpeep"],":") then
				splitrightpeep = mysplit(line["rightpeep"],"|")
				splitrightpeepcount = 1
				splitrightpeepframe = 1
				splitfirstrightpeep = mysplit(splitrightpeep[1],":")
				rightpeep = Graphics.image.new("assets/images/" .. splitfirstrightpeep[1])
				rightpeepSprite = Graphics.sprite.new(rightpeep)
			else
				rightpeep = Graphics.image.new("assets/images/" .. line["rightpeep"])
				rightpeepSprite = Graphics.sprite.new(rightpeep)
			end
			rightpeepSprite:setCenter(1, 0)
			rightpeepSprite:moveTo(400, 0)
			rightpeepSprite:add()
		end
	end
	splitleftpeeptalking=nil
	if line["leftpeeptalking"]~=nil then
		splitleftpeeptalking = mysplit(line["leftpeeptalking"],"|")
		splitleftpeeptalkingcount = 1
		splitleftpeeptalkingframe = 1
	end
	splitmiddlepeeptalking=nil
	if line["middlepeeptalking"]~=nil then
		splitmiddlepeeptalking = mysplit(line["middlepeeptalking"],"|")
		splitmiddlepeeptalkingcount = 1
		splitmiddlepeeptalkingframe = 1
	end
	splitrightpeeptalking=nil
	if line["rightpeeptalking"]~=nil then
		splitrightpeeptalking = mysplit(line["rightpeeptalking"],"|")
		splitrightpeeptalkingcount = 1
		splitrightpeeptalkingframe = 1
	end
	if line["whichpeep"]~=nil then
		saveData("gdwhichpeep", line["whichpeep"])
		if leftpeepSprite ~= nil then leftpeepSprite:moveTo(0,0) end
		if middlepeepSprite ~= nil then middlepeepSprite:moveTo(200,0) end
		if rightpeepSprite ~= nil then rightpeepSprite:moveTo(400,0) end
		if line["whichpeep"] == "left" then
			if leftpeepSprite~=nil then leftpeepSprite:moveTo(0,-10) end
		elseif line["whichpeep"] == "middle" then
			if middlepeepSprite~=nil then middlepeepSprite:moveTo(200,-10) end
		elseif line["whichpeep"] == "right" then
			if rightpeepSprite~=nil then rightpeepSprite:moveTo(400,-10) end
		end
	else
		saveData("gdwhichpeep", "")
	end
	if line["leftpeepflip"]~=nil then
		saveData("gdleftpeepflip", line["leftpeepflip"])
		if leftpeepSprite~=nil then leftpeepSprite:setImageFlip("flipX") end
	else
		saveData("gdleftpeepflip", "")
	end
	if line["middlepeepflip"]~=nil then
		saveData("gdmiddlepeepflip", line["middlepeepflip"])
		if middlepeepSprite~=nil then middlpeepSprite:setImageFlip("flipX") end
	else
		saveData("gdmiddlepeepflip", "")
	end
	if line["rightpeepflip"]~=nil then
		saveData("gdrightpeepflip", line["rightpeepflip"])
		if rightpeepSprite~=nil then rightpeepSprite:setImageFlip("flipX") end
	else
		saveData("gdrightpeepflip", "")
	end
end


function newsynth()
	local s = snd.synth.new(snd.kWaveSawtooth)
	s:setVolume(0.2)
	s:setAttack(0)
	s:setDecay(0.15)
	s:setSustain(0.2)
	s:setRelease(0)
	return s
end


function drumsynth(path, code)
	local sample = snd.sample.new(path)
	local s = snd.synth.new(sample)
	s:setVolume(0.5)
	return s
end


function newinst(n)
	local inst = snd.instrument.new()
	for i=1,n do
		inst:addVoice(newsynth())
	end
	return inst
end


function druminst()
	local inst = snd.instrument.new()
	inst:addVoice(drumsynth("assets/drums/kick"), 35)
	inst:addVoice(drumsynth("assets/drums/kick"), 36)
	inst:addVoice(drumsynth("assets/drums/snare"), 38)
	inst:addVoice(drumsynth("assets/drums/clap"), 39)
	inst:addVoice(drumsynth("assets/drums/tom-low"), 41)
	inst:addVoice(drumsynth("assets/drums/tom-low"), 43)
	inst:addVoice(drumsynth("assets/drums/tom-mid"), 45)
	inst:addVoice(drumsynth("assets/drums/tom-mid"), 47)
	inst:addVoice(drumsynth("assets/drums/tom-hi"), 48)
	inst:addVoice(drumsynth("assets/drums/tom-hi"), 50)
	inst:addVoice(drumsynth("assets/drums/hh-closed"), 42)
	inst:addVoice(drumsynth("assets/drums/hh-closed"), 44)
	inst:addVoice(drumsynth("assets/drums/hh-open"), 46)
	inst:addVoice(drumsynth("assets/drums/cymbal-crash"), 49)
	inst:addVoice(drumsynth("assets/drums/cymbal-ride"), 51)
	inst:addVoice(drumsynth("assets/drums/cowbell"), 56)
	inst:addVoice(drumsynth("assets/drums/clav"), 75)
	return inst
end


function soundCheck()
	if line["bgm"]~=nil then
		saveData("gdbgm", line["bgm"])
		if bgm~=nil then bgm:stop() end
		if line["bgm"]~="" then
			bgm = playdate.sound.fileplayer.new("assets/sounds/" .. line["bgm"])
			bgm:play(0)
		end	
	end
	if line["bgmidi"]~=nil then
		saveData("gdbgmidi", line["bgmidi"])
		if bgmidi~=nil then bgmidi:stop() end
		bgmidi = playdate.sound.sequence.new("assets/sounds/" .. line["bgmidi"])
		local ntracks = bgmidi:getTrackCount()
		local active = {}
		local poly = 0
		for i=1,ntracks do
			local track = bgmidi:getTrackAtIndex(i)
			if track ~= nil then
				local n = track:getPolyphony(i)
				if n > 0 then active[#active+1] = i end
				if n > poly then poly = n end
			
				if i == 10 then
					track:setInstrument(druminst(n))
				else
					track:setInstrument(newinst(n))
				end
			end
		end
		bgmidi:setLoops(0,bgmidi:getLength(),0)
		bgmidi:play()
	end
	if line["sfx"]~=nil then
		saveData("gdsfx", line["sfx"])
		if line["sfx"]~="" then
			sfx = playdate.sound.fileplayer.new("assets/sounds/" .. line["sfx"],5)
			sfx:play()
		else
			sfx:stop()
		end
	else
		saveData("gdsfx", "")
	end
end


function cursorActivate()
	cursoractive = "yes"
	cursorSprite = Graphics.sprite.new(cursor)
	cursorSprite:moveTo(cursorX, cursorY)
	cursorSprite:setCollideRect(0, 0, cursorSprite:getSize())
	cursorSprite:add()
end


function cursorRemove()
	cursoractive = "no"
	if cursorSprite~=nil then 
		cursorX = cursorSprite.x
		cursorY = cursorSprite.y
		cursorSprite:remove() 
	end
end


function cursorMover()
	if playdate.buttonIsPressed(playdate.kButtonUp) then
		if cursorSprite.y >= 8 then
			cursorSprite:moveBy(0, -2)
		end
	end
	if playdate.buttonIsPressed(playdate.kButtonRight) then
		if cursorSprite.x < 394 then
			cursorSprite:moveBy(2, 0)
		end
	end
	if playdate.buttonIsPressed(playdate.kButtonDown) then
		if cursorSprite.y < 234 then
			cursorSprite:moveBy(0, 2)
		end
	end
	if playdate.buttonIsPressed(playdate.kButtonLeft) then
		if cursorSprite.x >=8 then
			cursorSprite:moveBy(-2, 0)
		end
	end
	locations = mysplit(line["locations"],"|")
	cursorSprite:setImage(cursor)
	for _, locationspecs in ipairs(locations) do
		sqr = mysplit(locationspecs,":")
		areafound = gfx.sprite.querySpritesInRect(sqr[1],sqr[2],sqr[3],sqr[4])
		for _, area in ipairs(areafound) do
			cursorSprite:setImage(cursoron)
			if playdate.buttonJustPressed(playdate.kButtonA) then
				saveData("gdline", sqr[5])
				line = deepcopy(db[sqr[5]])
			end
		end
	end
end


function dump(o)
	if type(o) == 'table' then
	   local s = '{ '
	   for k,v in pairs(o) do
		  if type(k) ~= 'number' then k = '"'..k..'"' end
		  s = s .. '['..k..'] = ' .. dump(v) .. ','
	   end
	   return s .. '} '
	else
	   return tostring(o)
	end
end


function setVariables()
	if line["setvariables"]~=nil then
		local operations = mysplit(line["setvariables"],"|")
		for _, operation in ipairs(operations) do
			local thisoperation = mysplit(operation,":")
			vnvariables[thisoperation[1]] = thisoperation[2]
		end
		saveData("gdvariables", vnvariables)
	end
end


function replaceVariable(haystack)
	whilenum = 1
	while(string.find(haystack, "~" .. whilenum .. ".*" .. whilenum .. "~"))
	do
		i,j = string.find(haystack,"~" .. whilenum .. ".*" .. whilenum .. "~")
		local og = string.sub(haystack, i, j)
		local newguy = string.sub(haystack, i+2, j-2)
		if vnvariables[newguy]~=nil then haystack = string.gsub(haystack,og,vnvariables[newguy]) end
		whilenum = whilenum + 1
	end
	return haystack
end

function replaceAllVariables(haystack)
	for k, v in pairs(haystack) do
		haystack[k] = replaceVariable(v)
	end
	return haystack
end

function functionCheck()
	if(line["function"])~=nil then
		if(line["functionvariables"])~=nil then
			_G[line["function"]](line["functionvariables"])
		else
			_G[line["function"]]()
		end
	end
end

function overlayCheck()
    if line["overlay"]~=nil then
		saveData("gdoverlay", line["overlay"])
		if overlaySprite~=nil then overlaySprite:remove() end
		splitoverlay=nil
		if string.find(line["overlay"],"|") then
			splitoverlay = mysplit(line["overlay"],"|")
			splitoverlaycount = 1
			splitoverlayframe = 1
			splitfirstoverlay = mysplit(splitoverlay[1],":")
		else
			splitfirstoverlay = mysplit(line["overlay"],":")
		end
		overlay = Graphics.image.new("assets/images/" .. splitfirstoverlay[1])
		overlaySprite = Graphics.sprite.new(overlay)
		overlaySprite:setCenter(0, 0)
		overlaySprite:moveTo(splitfirstoverlay[2], splitfirstoverlay[3])	
		overlaySprite:add()
		overlaySprite:setZIndex(997)
    else
		saveData("gdoverlay", "")
		if overlaySprite~=nil then overlaySprite:remove() end
		if splitoverlay ~= nil then splitoverlay = nil end
	end
end

function dialogueEvent()
	noSaveCheck()
	line = replaceAllVariables(line)
	if line['autoadvance']~=nil then
		autoadvancecounter = 0
		autoadvancelimit = tonumber(line['autoadvance'])
	else
		autoadvancecounter=nil
		autoadvancelimit=nil
	end
	if line['disablebuttons']~=nil then
		disablebuttons = "yes"
	else
		disablebuttons = nil
	end
	functionCheck()
	overlayCheck()
	cursorRemove()
	soundCheck()
	dbBackgroundCheck()
	checkPeeps()
	setVariables()
	createTextbox()
end

function noSaveCheck()
	if line['nosave']~=nil then
		nosave = "yes"
	else
		saveLoadData()
		nosave = nil
	end
end

function loadCheck()
	if line['loadgame']~=nil then
		if Noble.GameData.get("ldline")~="" then line = deepcopy(db[Noble.GameData.get("ldline")]) end
		if Noble.GameData.get("ldbackground")~="" then line['background'] = Noble.GameData.get("ldbackground") end
		if Noble.GameData.get("gdleftpeep")~="" then line['leftpeep'] = Noble.GameData.get("ldleftpeep") end
		if Noble.GameData.get("gdmiddlepeep")~="" then line['middlepeep'] = Noble.GameData.get("ldmiddlepeep") end
		if Noble.GameData.get("gdrightpeep")~="" then line['rightpeep'] = Noble.GameData.get("ldrightpeep") end
		if Noble.GameData.get("gdwhichpeep")~="" then line['whichpeep'] = Noble.GameData.get("ldwhichpeep") end
		if Noble.GameData.get("gdleftpeepflip")~="" then line['leftpeepflip'] = Noble.GameData.get("ldleftpeepflip") end
		if Noble.GameData.get("gdmiddlepeepflip")~="" then line['middlepeepflip'] = Noble.GameData.get("ldmiddlepeepflip") end
		if Noble.GameData.get("gdrightpeepflip")~="" then line['rightpeepflip'] = Noble.GameData.get("ldrightpeepflip") end
		if Noble.GameData.get("ldbgm")~="" then line['bgm'] = Noble.GameData.get("ldbgm") end
		if Noble.GameData.get("ldbgmidi")~="" then line['bgmidi'] = Noble.GameData.get("ldbgmidi") end
		if Noble.GameData.get("ldsfx")~="" then line['sfx'] = Noble.GameData.get("ldsfx") end
		if Noble.GameData.get("ldvariables")~="" then vnvariables = Noble.GameData.get("ldvariables") end
		if Noble.GameData.get("ldoverlay")~="" then line['overlay'] = Noble.GameData.get("ldoverlay") end
		justloaded = "yes"
		cursoractive = "no"
		isinmenu = "no"
		print(dump(line))
	end
end

function saveData(savevariable,data)
	if nosave==nil then
		Noble.GameData.set(savevariable, data)
	end
end

function saveLoadData()
	Noble.GameData.set("ldline",Noble.GameData.get("gdline"))
	Noble.GameData.set("ldbackground",Noble.GameData.get("gdbackground"))
	Noble.GameData.set("ldleftpeep",Noble.GameData.get("gdleftpeep"))
	Noble.GameData.set("ldmiddlepeep",Noble.GameData.get("gdmiddlepeep"))
	Noble.GameData.set("ldrightpeep",Noble.GameData.get("gdrightpeep"))
	Noble.GameData.set("ldwhichpeep",Noble.GameData.get("gdwhichpeep"))
	Noble.GameData.set("ldleftpeepflip",Noble.GameData.get("gdleftpeepflip"))
	Noble.GameData.set("ldmiddlepeepflip",Noble.GameData.get("gdmiddlepeepflip"))
	Noble.GameData.set("ldrightpeepflip",Noble.GameData.get("gdrightpeepflip"))
	Noble.GameData.set("ldbgm",Noble.GameData.get("gdbgm"))
	Noble.GameData.set("ldbgmidi",Noble.GameData.get("gdbgmidi"))
	Noble.GameData.set("ldsfx",Noble.GameData.get("gdsfx"))
	Noble.GameData.set("ldvariables",Noble.GameData.get("gdvariables"))
	Noble.GameData.set("ldoverlay",Noble.GameData.get("gdoverlay"))
end

function checkEventType()
	if(line['loadgame'])~=nil then
		print("LOADING")
		print(dump(line))
		loadCheck()
	else
		if disablebuttons==nil then
			if (playdate.buttonJustPressed(playdate.kButtonB)) then
				onPressB()
			end
			et = line["eventtype"]
			if textbox~=nil and textbox.typing then
				if playdate.buttonJustPressed(playdate.kButtonA) then
					textbox.currentChar = 9999
				end
			else
				if et == "dialogue" then
					if (playdate.buttonJustPressed(playdate.kButtonA) or playdate.buttonJustPressed(playdate.kButtonB) or justloaded == "yes") then
						dialogueEvent()
					end
				elseif et == "menu" then
					if (playdate.buttonJustPressed(playdate.kButtonA) or playdate.buttonJustPressed(playdate.kButtonB) or justloaded == "yes") then
						noSaveCheck()
						line = replaceAllVariables(line)
						functionCheck()
						overlayCheck()
						cursorRemove()
						soundCheck()
						dbBackgroundCheck()
						checkPeeps()
						setVariables()
						createDialogueMenu()
					end
				elseif et == "scene" then	
					if (playdate.buttonJustPressed(playdate.kButtonA) or playdate.buttonJustPressed(playdate.kButtonB) or justloaded == "yes") then
						noSaveCheck()
						line = replaceAllVariables(line)
						functionCheck()
						overlayCheck()
						cursorRemove()
						setVariables()
						changeScene()
						print("what")
					end
				elseif et == "inspect" then
					if (playdate.buttonJustPressed(playdate.kButtonA) or playdate.buttonJustPressed(playdate.kButtonB) or justloaded == "yes") then
						noSaveCheck()
						line = replaceAllVariables(line)
						functionCheck()
						overlayCheck()
						cursorRemove()
						soundCheck()
						dbBackgroundCheck()
						checkPeeps()
						clearDialogue()
						setVariables()
						cursorActivate()
					end
				end
				justloaded = ""
			end
		end
	end
end

function checkMenuStuff()
	if playdate.buttonJustPressed(playdate.kButtonA) then
		thisrow = gridview:getSelectedRow()
		isinmenu = "no"
		gridviewSprite:remove()
		saveData("gdline", lineoptions[thisrow])
		line = deepcopy(db[lineoptions[thisrow]])
		checkEventType()
	end
	if playdate.buttonJustPressed(playdate.kButtonUp) then
		gridview:selectPreviousRow(true)
	elseif playdate.buttonJustPressed(playdate.kButtonDown) then
		gridview:selectNextRow(true)
	end
	local crankTicks = playdate.getCrankTicks(2)
	if crankTicks == 1 then
		gridview:selectNextRow(true)
	elseif crankTicks == -1 then
		gridview:selectPreviousRow(true)
	end
	if gridview.needsDisplay then
		local gridviewImage = Graphics.image.new(300, contentgridheight)
		Graphics.pushContext(gridviewImage)
			gridview:drawInRect(0, 0, 300, contentgridheight)
		Graphics.popContext()
		gridviewSprite:setImage(gridviewImage)
		gridviewSprite:setZIndex(999)
	end
end


