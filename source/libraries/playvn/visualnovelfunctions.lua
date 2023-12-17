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
	-- now let's put together the textbox sprite
	if (line["content"]~=nil)then
		if textbox == nil then
			textbox = Graphics.sprite.new()
		end
		textbox:setSize(400, 60)
		textbox:setCenter(0,0)
		textbox:moveTo(0, 190)
		textbox:setZIndex(998)
		textbox.text = "" -- this is blank for now; we can set it at any point
		textbox.currentChar = 1 -- Start the current character as the first one
		textbox.next40 = 40 -- the next point at which we will pause is 40 characters, the starting amount
		textbox.paused = false -- we are not currently pausing the text box
		textbox.currentText = "" -- Currently the text to print is blank
		textbox.typing = true -- we are starting typing

		-- this function will calculate the string to be used. 
		-- it won't actually draw it; the following draw() function will.
		function textbox:update() -- This runs every update on the text box, I guess?
			if self.paused or (self.typing==false) then
				if pressastate >= 30 then pressastate = 0 end
				pressastate = pressastate + 1
				if pressastate < 15 then
					pressapic = Graphics.image.new("assets/images/pressa")
				elseif pressastate < 30 then
					pressapic = Graphics.image.new("assets/images/pressa2")
				end
				if pressa == nil then
					pressa = Graphics.sprite.new(pressapic)
				else
					pressa:setImage(pressapic)
				end
				pressa:setCenter(0, 0)
				pressa:moveTo(377, 219)
				pressa:setZIndex(999)
				pressa:add()
			else
				if pressa~=nil then
					pressa:remove()
				end
				self.currentChar = self.currentChar + 1 -- increase currentchar by one
				if self.currentChar > #self.text then -- if currentchar is bigger than the length of the text string, instead keep currentchar at the length of the text string
					self.currentChar = #self.text
				end
				if self.typing and self.currentChar <= #self.text then -- if we are still typing and currentchar is less than, or equal to the length of the text string...
					textbox.currentText = string.sub(self.text, 1, self.currentChar) -- set the textbox.currentText to be the amount of characters from the text string defined by currentChar
					textbox.nextText = string.sub(self.text, 1, (self.currentChar + 1))
					self:markDirty() -- this tells the sprite that it needs to redraw
				end
				-- end typing
				if self.currentChar == #self.text then -- if currentchar is the same length as the text string, then...
					self.currentChar = 1 -- reset currentchar to 1 ready for the next time and...
					self.next40 = 40
					self.typing = false -- mark that we have stopped typing so we stop running this update.
				end	
			end
		end

		-- this function defines how the textbox is drawn and then writes the text into it. The actual text that will be written in is defined further down.
		function textbox:draw()
			Graphics.pushContext()
			-- draw the box				
			Graphics.setColor(Graphics.kColorWhite)
			Graphics.fillRect(0,0,400,60)
			-- border
			Graphics.setLineWidth(4)
			Graphics.setColor(Graphics.kColorBlack)
			Graphics.drawRect(0,0,400,60)
			-- draw the text!
			local textYpos = 10 -- the text's starting position, 10px down from the top of the box
			local currentTextWidth, currentTextHeight = Graphics.getTextSize(self.currentText) -- get the height of the current text box
			local nextTextWidth, nextTextHeight = Graphics.getTextSize(self.nextText) -- get the height of the NEXT text box
			if currentTextHeight > 40 then -- is the current text bigger than the height of the text box (40px or two rows of 20px)? if so then
				textYpos = textYpos - (currentTextHeight - 40) -- set the position of the text as the starting text position (10px) minus 40 LESS than the current text height, so the bottom of the text is the second row of the text box
			end
			if nextTextHeight > self.next40 then
				self.paused = true
				self.next40 = self.next40 + 40
			end
			local thistextwidth, thistextheight, thistexttruncated = Graphics.drawTextInRect(self.currentText, 10, textYpos, 380, currentTextHeight, nil, '...')
			Graphics.popContext()
		end

		-- make a copy of the text
		local linecheckedtext = line["content"]
		-- is the text longer than one line of the dialogue box?
		local startspace = 0
		while Graphics.getTextSize(linecheckedtext)>=372 do
			-- set foundspace as zero
			local foundspace = startspace
			local previousspace = nil
			-- loop until we break
			while true do
				-- get the locations of the first instance of a space after the last one (or start of the string)
   				foundspace = linecheckedtext:find(" ", foundspace+1)
				-- if we found no more spaces then stop what we're doing
   				if foundspace==nil then
					if(previousspace~=nil) then
						linecheckedtext = replace_char(previousspace, linecheckedtext, "\n")
						break
					end
					break
				end
				-- if the length of the string leading up to this space is longer than the length of a text box then
   				if(Graphics.getTextSize(string.sub(linecheckedtext,startspace,foundspace))>=372)then
					-- replace the PREVIOUS space we found with a line break IF we found a previous space.
					if(previousspace~=nil) then
						linecheckedtext = replace_char(previousspace, linecheckedtext, "\n")
						startspace = previousspace
						break
					end
				end
				previousspace = foundspace
			end
		end
		textbox.text = linecheckedtext
		textbox:add()
	else
		if textbox~=nil then textbox:remove() end
	end
	if line["whospeaking"]~=nil then
		local whoboxlen = Graphics.getTextSize(line["whospeaking"]) + 10
		if whobox == nil then
			whobox = Graphics.sprite.new()
		end
		whobox:setSize(whoboxlen, 26)
		whobox:setCenter(0,0)
		whobox:moveTo(4, 170)
		whobox:setZIndex(999)
		whobox.text = ""
		whobox.currentText = line["whospeaking"]
		
		function whobox:draw()
			Graphics.pushContext()
				-- draw the box				
				Graphics.setColor(Graphics.kColorWhite)
				Graphics.fillRoundRect(0,0,whoboxlen,26,4)
				-- border
				Graphics.setLineWidth(1)
				Graphics.setColor(Graphics.kColorBlack)
				Graphics.drawRoundRect(0,0,whoboxlen,26,4)
				-- draw the text!
				Graphics.drawTextInRect(self.currentText, 4, 4, whoboxlen, 20)
			Graphics.popContext()
		end
		whobox.text = line["whospeaking"]
		whobox:add()
	else
		if whobox ~= nil then whobox:remove() end
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
		currentbackground = mysplit(splitbackground[splitbackgroundcount],":")
		if (tonumber(currentbackground[2]) < splitbackgroundframe and currentbackground[2]~="0") then
			splitbackgroundcount = splitbackgroundcount + 1
			splitbackgroundframe = 1
			if splitbackground[splitbackgroundcount]==nil then splitbackgroundcount = 1 end
			currentbackground = mysplit(splitbackground[splitbackgroundcount],":")
			background = Graphics.image.new("assets/images/" .. currentbackground[1])
			if backgroundSprite == nil then
				backgroundSprite = Graphics.sprite.new(background)
			else
				backgroundSprite:setImage(background)
			end
			backgroundSprite:setCenter(0.5, 0)
			backgroundSprite:moveTo(200, 0)
			backgroundSprite:add()
		end
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
			overlay = Graphics.image.new("assets/images/" .. currentoverlay[1])
			overlaySprite = Graphics.sprite.new(overlay)
			overlaySprite:setCenter(0, 0)
			overlaySprite:moveTo(currentoverlay[2], currentoverlay[3])
			overlaySprite:setZIndex(997)
			overlaySprite:add()
		end
		splitoverlayframe = splitoverlayframe + 1
	end
	if splitleftpeep~=nil then
		if textbox~=nil and textbox.typing and not textbox.paused and splitleftpeeptalking~=nil then
			currentleftpeep = mysplit(splitleftpeeptalking[splitleftpeeptalkingcount],":")
			if (tonumber(currentleftpeep[2]) < splitleftpeeptalkingframe and currentleftpeep[2]~="0") then
				splitleftpeeptalkingcount = splitleftpeeptalkingcount + 1
				splitleftpeeptalkingframe = 1
				if splitleftpeeptalking[splitleftpeeptalkingcount]==nil then splitleftpeeptalkingcount = 1 end
				currentleftpeep = mysplit(splitleftpeeptalking[splitleftpeeptalkingcount],":")
				leftpeep = Graphics.image.new("assets/images/" .. currentleftpeep[1])
				if leftpeepSprite == nil then
					leftpeepSprite = Graphics.sprite.new(leftpeep)
				else
					leftpeepSprite:setImage(leftpeep)
				end
				leftpeepSprite:setCenter(0.5, 0)
				leftpeepSprite:moveTo(leftpeepoffset, 0)
				leftpeepSprite:add()
			end
			splitleftpeeptalkingframe = splitleftpeeptalkingframe + 1
		else
			currentleftpeep = mysplit(splitleftpeep[splitleftpeepcount],":")
			if (tonumber(currentleftpeep[2]) < splitleftpeepframe and currentleftpeep[2]~="0") then
				splitleftpeepcount = splitleftpeepcount + 1
				splitleftpeepframe = 1
				if splitleftpeep[splitleftpeepcount]==nil then splitleftpeepcount = 1 end
				currentleftpeep = mysplit(splitleftpeep[splitleftpeepcount],":")
				leftpeep = Graphics.image.new("assets/images/" .. currentleftpeep[1])
				if leftpeepSprite == nil then
					leftpeepSprite = Graphics.sprite.new(leftpeep)
				else
					leftpeepSprite:setImage(leftpeep)
				end
				leftpeepSprite:setCenter(0.5, 0)
				leftpeepSprite:moveTo(leftpeepoffset, 0)
				leftpeepSprite:add()
			end
			splitleftpeepframe = splitleftpeepframe + 1
		end
	end
	if splitmiddlepeep~=nil then
		if textbox~=nil and textbox.typing and not textbox.paused and splitmiddlepeeptalking~=nil then
			currentmiddlepeep = mysplit(splitmiddlepeeptalking[splitmiddlepeeptalkingcount],":")
			if (tonumber(currentmiddlepeep[2]) < splitmiddlepeeptalkingframe and currentmiddlepeep[2]~="0") then
				splitmiddlepeeptalkingcount = splitmiddlepeeptalkingcount + 1
				splitmiddlepeeptalkingframe = 1
				if splitmiddlepeeptalking[splitmiddlepeeptalkingcount]==nil then splitmiddlepeeptalkingcount = 1 end
				currentmiddlepeep = mysplit(splitmiddlepeeptalking[splitmiddlepeeptalkingcount],":")
				middlepeep = Graphics.image.new("assets/images/" .. currentmiddlepeep[1])
				if middlepeepSprite == nil then
					middlepeepSprite = Graphics.sprite.new(middlepeep)
				else
					middlepeepSprite:setImage(middlepeep)
				end
				middlepeepSprite:setCenter(0.5, 0)
				middlepeepSprite:moveTo(middlepeepoffset, 0)
				middlepeepSprite:add()
			end
			splitmiddlepeeptalkingframe = splitmiddlepeeptalkingframe + 1
		else
			currentmiddlepeep = mysplit(splitmiddlepeep[splitmiddlepeepcount],":")
			if (tonumber(currentmiddlepeep[2]) < splitmiddlepeepframe and currentmiddlepeep[2]~="0") then
				splitmiddlepeepcount = splitmiddlepeepcount + 1
				splitmiddlepeepframe = 1
				if splitmiddlepeep[splitmiddlepeepcount]==nil then splitmiddlepeepcount = 1 end
				currentmiddlepeep = mysplit(splitmiddlepeep[splitmiddlepeepcount],":")
				middlepeep = Graphics.image.new("assets/images/" .. currentmiddlepeep[1])
				if middlepeepSprite == nil then
					middlepeepSprite = Graphics.sprite.new(middlepeep)
				else
					middlepeepSprite:setImage(middlepeep)
				end
				middlepeepSprite:setCenter(0.5, 0)
				middlepeepSprite:moveTo(middlepeepoffset, 0)
				middlepeepSprite:add()
			end
			splitmiddlepeepframe = splitmiddlepeepframe + 1
		end
	end
	if splitrightpeep~=nil then
		if textbox~=nil and textbox.typing and not textbox.paused and splitrightpeeptalking~=nil then
			currentrightpeep = mysplit(splitrightpeeptalking[splitrightpeeptalkingcount],":")
			if (tonumber(currentrightpeep[2]) < splitrightpeeptalkingframe and currentrightpeep[2]~="0")then
				splitrightpeeptalkingcount = splitrightpeeptalkingcount + 1
				splitrightpeeptalkingframe = 1
				if splitrightpeeptalking[splitrightpeeptalkingcount]==nil then splitrightpeeptalkingcount = 1 end
				currentrightpeep = mysplit(splitrightpeeptalking[splitrightpeeptalkingcount],":")
				rightpeep = Graphics.image.new("assets/images/" .. currentrightpeep[1])
				if rightpeepSprite == nil then
					rightpeepSprite = Graphics.sprite.new(rightpeep)
				else
					rightpeepSprite:setImage(rightpeep)
				end
				rightpeepSprite:setCenter(0.5, 0)
				rightpeepSprite:moveTo(rightpeepoffset, 0)
				rightpeepSprite:add()	
			end
			splitrightpeeptalkingframe = splitrightpeeptalkingframe + 1
		else
			currentrightpeep = mysplit(splitrightpeep[splitrightpeepcount],":")
			if (tonumber(currentrightpeep[2]) < splitrightpeepframe and currentrightpeep[2]~="0") then
				splitrightpeepcount = splitrightpeepcount + 1
				splitrightpeepframe = 1
				if splitrightpeep[splitrightpeepcount]==nil then splitrightpeepcount = 1 end
				currentrightpeep = mysplit(splitrightpeep[splitrightpeepcount],":")
				rightpeep = Graphics.image.new("assets/images/" .. currentrightpeep[1])
				if rightpeepSprite == nil then
					rightpeepSprite = Graphics.sprite.new(rightpeep)
				else
					rightpeepSprite:setImage(rightpeep)
				end
				rightpeepSprite:setCenter(0.5, 0)
				rightpeepSprite:moveTo(rightpeepoffset, 0)
				rightpeepSprite:add()	
			end
			splitrightpeepframe = splitrightpeepframe + 1
		end
	end
	local getwhichpeep = savetemp["gdwhichpeep"]
	if getwhichpeep == "left" then
		if leftpeepSprite~=nil then leftpeepSprite:moveTo(leftpeepoffset,-10) end
	elseif getwhichpeep == "middle" then
		if middlepeepSprite~=nil then middlepeepSprite:moveTo(middlepeepoffset,-10) end
	elseif getwhichpeep == "right" then
		if rightpeepSprite~=nil then rightpeepSprite:moveTo(rightpeepoffset,-10) end
	end
	if(savetemp["gdleftpeepflip"]~=nil and savetemp["gdleftpeepflip"]~="") then
		if leftpeepSprite~=nil then leftpeepSprite:setImageFlip("flipX") end
	end
	if(savetemp["gdmiddlepeepflip"]~=nil and savetemp["gdmiddlepeepflip"]~="") then
		if middlepeepSprite~=nil then middlepeepSprite:setImageFlip("flipX") end
	end
	if(savetemp["gdrightpeepflip"]~=nil and savetemp["gdrightpeepflip"]~="") then
		if rightpeepSprite~=nil then rightpeepSprite:setImageFlip("flipX") end
	end
end

function changeScene()
	local thisduration = "1.5"
	if line["duration"]~=nil then
		thisduration = line["duration"]
	end
	if line["newscene"]~=nil then
		PVNtoscene = line["newscene"]
	else
		PVNtoscene = thisscenename
	end
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
end

function dbBackgroundCheck(nosave)
    if line["background"]~=nil then
		if nosave~="nosave" then saveData("gdbackground", line["background"]) end
		splitbackground=nil
		if string.find(line["background"],":") then
			splitbackground = mysplit(line["background"],"|")
			splitbackgroundcount = 1
			splitbackgroundframe = 1
			splitfirstbackground = mysplit(splitbackground[1],":")
			background = Graphics.image.new("assets/images/" .. splitfirstbackground[1])
			if backgroundSprite==nil then
				backgroundSprite = Graphics.sprite.new(background)
			else
				backgroundSprite:setImage(background)
			end
		else
			background = Graphics.image.new("assets/images/" .. line["background"])
			if backgroundSprite==nil then
				backgroundSprite = Graphics.sprite.new(background)
			else
				backgroundSprite:setImage(background)
			end
		end
		backgroundSprite:setCenter(0, 0)
		backgroundSprite:moveTo(0, 0)
		backgroundSprite:add()
    end
end

function clearPeeps()
	saveData("gdleftpeep", "")
	saveData("gdmiddlepeep", "")
	saveData("gdrightpeep", "")
	if leftpeepSprite~=nil then 
		leftpeepSprite:remove()	
	end
	if middlepeepSprite~=nil then 
		middlepeepSprite:remove()	
	end
	if rightpeepSprite~=nil then 
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
			if string.find(line["leftpeep"],":") then
				splitleftpeep = mysplit(line["leftpeep"],"|")
				splitleftpeepcount = 1
				splitleftpeepframe = 1
				splitfirstleftpeep = mysplit(splitleftpeep[1],":")
				leftpeep = Graphics.image.new("assets/images/" .. splitfirstleftpeep[1])
				if leftpeepSprite == nil then 
					leftpeepSprite = Graphics.sprite.new(leftpeep)
				else
					leftpeepSprite:setImage(leftpeep)
				end
			else
				leftpeep = Graphics.image.new("assets/images/" .. line["leftpeep"])
				if leftpeepSprite ~= nil then 
					leftpeepSprite = Graphics.sprite.new(leftpeep)
				else
					leftpeepSprite:setImage(leftpeep)
				end
			end
			leftpeepSprite:setCenter(0, 0)
			leftpeepSprite:moveTo(leftpeepoffset, 0)
			leftpeepSprite:add()
		end
	end
	if line["middlepeep"]~=nil then
		saveData("gdmiddlepeep", line["middlepeep"])
		splitmiddlepeep=nil
		if line["middlepeep"]=="" then
			if middlepeepSprite ~= nil then middlepeepSprite:remove() end
		else
			if string.find(line["middlepeep"],":") then
				splitmiddlepeep = mysplit(line["middlepeep"],"|")
				splitmiddlepeepcount = 1
				splitmiddlepeepframe = 1
				splitfirstmiddlepeep = mysplit(splitmiddlepeep[1],":")
				middlepeep = Graphics.image.new("assets/images/" .. splitfirstmiddlepeep[1])
				if middlepeepSprite == nil then
					middlepeepSprite = Graphics.sprite.new(middlepeep)
				else
					middlepeepSprite:setImage(middlepeep)
				end
			else
				middlepeep = Graphics.image.new("assets/images/" .. line["middlepeep"])
				if middlepeepSprite == nil then
					middlepeepSprite = Graphics.sprite.new(middlepeep)
				else
					middlepeepSprite:setImage(middlepeep)
				end
			end
			middlepeepSprite:setCenter(0.5, 0)
			middlepeepSprite:moveTo(middlepeepoffset, 0)
			middlepeepSprite:add()
		end
	end
	if line["rightpeep"]~=nil then
		saveData("gdrightpeep", line["rightpeep"])
		splitrightpeep=nil
		if line["rightpeep"]=="" then
			if rightpeepSprite ~= nil then rightpeepSprite:remove() end
		else
			if string.find(line["rightpeep"],":") then
				splitrightpeep = mysplit(line["rightpeep"],"|")
				splitrightpeepcount = 1
				splitrightpeepframe = 1
				splitfirstrightpeep = mysplit(splitrightpeep[1],":")
				rightpeep = Graphics.image.new("assets/images/" .. splitfirstrightpeep[1])
				if rightpeepSprite ~= nil then
					rightpeepSprite = Graphics.sprite.new(rightpeep)
				else
					rightpeepSprite:setImage(rightpeep)
				end
			else
				rightpeep = Graphics.image.new("assets/images/" .. line["rightpeep"])
				if rightpeepSprite ~= nil then
					rightpeepSprite = Graphics.sprite.new(rightpeep)
				else
					rightpeepSprite:setImage(rightpeep)
				end
			end
			rightpeepSprite:setCenter(1, 0)
			rightpeepSprite:moveTo(rightpeepoffset, 0)
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
		if leftpeepSprite ~= nil then leftpeepSprite:moveTo(leftpeepoffset,0) end
		if middlepeepSprite ~= nil then 
			middlepeepSprite:moveTo(middlepeepoffset,0) 
		end
		if rightpeepSprite ~= nil then rightpeepSprite:moveTo(rightpeepoffset,0) end
		if line["whichpeep"] == "left" then
			if leftpeepSprite~=nil then leftpeepSprite:moveTo(leftpeepoffset,-10) end
		elseif line["whichpeep"] == "middle" then
			if middlepeepSprite~=nil then 
				middlepeepSprite:moveTo(middlepeepoffset,-10) 
			end
		elseif line["whichpeep"] == "right" then
			if rightpeepSprite~=nil then rightpeepSprite:moveTo(rightpeepoffset,-10) end
		end
	else
		if leftpeepSprite~=nil then leftpeepSprite:moveTo(leftpeepoffset, 0) end
		if middlepeepSprite~=nil then middlepeepSprite:moveTo(middlepeepoffset, 0) end
		if rightpeepSprite~=nil then rightpeepSprite:moveTo(rightpeepoffset, 0) end
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
	cursorSprite:setZIndex(999)
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
		sqr = replaceAllVariables(sqr)
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


-- THIS IS ONLY USED FOR TESTING
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
-- END

function setVariables()
	if line["setvariables"]~=nil then
		local operations = mysplit(line["setvariables"],"|")
		for _, operation in ipairs(operations) do
			local thisoperation = mysplit(operation,":")
			vnvariables[thisoperation[1]] = thisoperation[2]
		end
		-- saveData("gdvariables", vnvariables)
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
		if line["loadgame"] == "inventory" then 
			dropOutOfInventoryCheck()
		else
			if Noble.GameData.get("ldline")~="" then line = deepcopy(db[Noble.GameData.get("ldline")]) end
			if Noble.GameData.get("gdbackground")~="" then line['background'] = Noble.GameData.get("gdbackground") end
			if Noble.GameData.get("gdleftpeep")~="" then line['leftpeep'] = Noble.GameData.get("gdleftpeep") end
			if Noble.GameData.get("gdmiddlepeep")~="" then line['middlepeep'] = Noble.GameData.get("gdmiddlepeep") end
			if Noble.GameData.get("gdrightpeep")~="" then line['rightpeep'] = Noble.GameData.get("gdrightpeep") end
			if Noble.GameData.get("gdwhichpeep")~="" then line['whichpeep'] = Noble.GameData.get("gdwhichpeep") end
			if Noble.GameData.get("gdleftpeepflip")~="" then line['leftpeepflip'] = Noble.GameData.get("gdleftpeepflip") end
			if Noble.GameData.get("gdmiddlepeepflip")~="" then line['middlepeepflip'] = Noble.GameData.get("gdmiddlepeepflip") end
			if Noble.GameData.get("gdrightpeepflip")~="" then line['rightpeepflip'] = Noble.GameData.get("gdrightpeepflip") end
			if Noble.GameData.get("gdbgm")~="" then line['bgm'] = Noble.GameData.get("ldbgm") end
			if Noble.GameData.get("gdbgmidi")~="" then line['bgmidi'] = Noble.GameData.get("ldbgmidi") end
			if Noble.GameData.get("gdsfx")~="" then line['sfx'] = Noble.GameData.get("gdsfx") end
			if Noble.GameData.get("gdvariables")~="" then vnvariables = Noble.GameData.get("ldvariables") end
			if Noble.GameData.get("gdoverlay")~="" then line['overlay'] = Noble.GameData.get("gdoverlay") end
			justloaded = "yes"
			cursoractive = "no"
			isinmenu = "no"
		end
	end
end

function dropOutOfInventoryCheck()
	if line['loadgame']~=nil then
		if savetemp["ldline"]~="" then line = deepcopy(db[savetemp["ldline"]]) end
		if savetemp["gdbackground"]~="" then line['background'] = savetemp["gdbackground"] end
		if savetemp["gdleftpeep"]~="" then line['leftpeep'] = savetemp["gdleftpeep"] end
		if savetemp["gdmiddlepeep"]~="" then line['middlepeep'] = savetemp["gdmiddlepeep"] end
		if savetemp["gdrightpeep"]~="" then line['rightpeep'] = savetemp["gdrightpeep"] end
		if savetemp["gdwhichpeep"]~="" then line['whichpeep'] = savetemp["gdwhichpeep"] end
		if savetemp["gdleftpeepflip"]~="" then line['leftpeepflip'] = savetemp["gdleftpeepflip"] end
		if savetemp["gdmiddlepeepflip"]~="" then line['middlepeepflip'] = savetemp["gdmiddlepeepflip"] end
		if savetemp["gdrightpeepflip"]~="" then line['rightpeepflip'] = savetemp["gdrightpeepflip"] end
		if savetemp["gdbgm"]~="" then line['bgm'] = savetemp["gdbgm"] end
		if savetemp["gdbgmidi"]~="" then line['bgmidi'] = savetemp["gdbgmidi"] end
		if savetemp["gdsfx"]~="" then line['sfx'] = savetemp["gdsfx"] end
		if savetemp["gdoverlay"]~="" then line['overlay'] = savetemp["gdoverlay"] end
		justloaded = "yes"
		cursoractive = "no"
		isinmenu = "no"
	end
end

function saveData(savevariable,data)
	if nosave==nil then
		savetemp[savevariable] = data
	end
end

function saveLoadData()
	if justloaded=="yes" then
	else
		savetemp["ldline"] = savetemp["gdline"]
		savetemp["ldbackground"] = savetemp["gdbackground"]
		savetemp["ldleftpeep"] = savetemp["gdleftpeep"]
		savetemp["ldmiddlepeep"] = savetemp["gdmiddlepeep"]
		savetemp["ldrightpeep"] = savetemp["gdrightpeep"]
		savetemp["ldwhichpeep"] = savetemp["gdwhichpeep"]
		savetemp["ldleftpeepflip"] = savetemp["gdleftpeepflip"]
		savetemp["ldmiddlepeepflip"] = savetemp["gdmiddlepeepflip"]
		savetemp["ldrightpeepflip"] = savetemp["gdrightpeepflip"]
		savetemp["ldbgm"] = savetemp["gdbgm"]
		savetemp["ldbgmidi"] = savetemp["gdbgmidi"]
		savetemp["ldsfx"] = savetemp["gdsfx"]
		savetemp["ldvariables"] = savetemp["gdvariables"]
		savetemp["ldoverlay"] = savetemp["gdoverlay"]
	end
end

function playdate.gameWillTerminate()
	saveDataToDisk()
end
function playdate.deviceWillSleep()
	saveDataToDisk()
end
function playdate.deviceWillLock()
	saveDataToDisk()
end

function saveDataToDisk()
	for key, value in pairs(savetemp) do Noble.GameData.set(key,value) end
end


function checkEventType()
	if(line['loadgame'])~=nil then
		loadCheck()
	else
		if disablebuttons==nil then
			if (playdate.buttonJustPressed(playdate.kButtonB)) then
				onPressB()
			end
			et = line["eventtype"]
			if textbox~=nil and textbox.typing and textbox.paused then
				if playdate.buttonJustPressed(playdate.kButtonA) then
					textbox.paused = false
				end
			else
				if textbox~=nil and textbox.typing then
					if playdate.buttonIsPressed(playdate.kButtonA) then
						local maybeText = string.sub(textbox.text, 1, (textbox.currentChar + 6))
						local maybeTextWidth, maybeTextHeight = Graphics.getTextSize(maybeText)
						if maybeTextHeight < textbox.next40 then
							textbox.currentChar = textbox.currentChar + 6
						end 
					end
				else
					if et == "dialogue" then
						if (playdate.buttonJustPressed(playdate.kButtonA) or playdate.buttonJustPressed(playdate.kButtonB) or justloaded == "yes") then
							dialogueEvent()
						end
					elseif et == "menu" then
						if (playdate.buttonJustPressed(playdate.kButtonA) or playdate.buttonJustPressed(playdate.kButtonB) or justloaded == "yes") then
							if pressa ~= nil then pressa:remove() end
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
							if pressa ~= nil then pressa:remove() end
							noSaveCheck()
							line = replaceAllVariables(line)
							functionCheck()
							overlayCheck()
							cursorRemove()
							setVariables()
							changeScene()
						end
					elseif et == "inspect" then
						if (playdate.buttonJustPressed(playdate.kButtonA) or playdate.buttonJustPressed(playdate.kButtonB) or justloaded == "yes") then
							if pressa ~= nil then pressa:remove() end
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
