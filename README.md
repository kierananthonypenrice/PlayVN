# PlayVN

A visual novel development plugin for Noble Engine.


## What is it?

PlayVN is a visual novel engine for the Panic Playdate designed to be as easy to use as possible. After completing the simple installation steps in this guide the entire game can be created by editing a single .json file in a fashion that should be easy to understand for those not familiar with programming. This was the guiding principle in creating this system: to make a visual novel engine that is very easy to use, but covers as many possible features of a visual novel as possible so as not to reduce functionality. In addition, the system is a plugin for the fantastic Noble Engine, so it can be easily integrated with other scenes to make the visual novel element just a part of your game.


## Installation Instructions

### Step 1: 
Download and install the latest version of the playdate sdk.  
https://play.date/dev/ 


### Step 2:
Download PlayVN


### Step 3:
Download the latest version of noble engine.  
https://github.com/NobleRobot/NobleEngine 


### Step 4: 
Download the latest version of noble engine's project template.  
https://github.com/NobleRobot/NobleEngine-ProjectTemplate 


### Step 5: 
Create a folder for your project on your PC.


### Step 6:
Extract the Noble Engine project template into the project folder.


### Step 7:
Extract the Noble Engine zip into the /source/libraries/noble/ folder in your project folder.


### Step 8:
Extract PlayVN into the folder, overwriting any files you are prompted to.


### Step 9:
Download the latest version of Visual Studio Code and install it


### Step 10: 
Open your game folder in Visual Studio Code. 

You can now select 'terminal -> run build task' to build the demo and run it in simulator. Visual Studio Code may ask you to install extensions and Powershell. Do so. 

If you encounter an error saying 'cannot be loaded because running scripts is disabled on this system' then follow these steps:  
	i) right click on the start menu and select windows powershell(admin)  
	ii) enter the command Set-ExecutionPolicy RemoteSigned  
	iii) Press Y when prompted  

If you encounter an error about 'pdc', please follow this guide:  
https://devforum.play.date/t/tutorial-compiling-lua-projects-on-windows/3332  
up to and including step 7. You will have to restart Visual Studio Code afterwards.


## First steps

First things first, now you have successfully 'built' the demo, take the time to play through it as it demonstrates some of the features of PlayVN, which will help you to understand the systems explained later in these instructions.

After that, I would recommend starting by editing the PlayVNDemo.json in /source/assets/json. This is the file that contains all of the dialogue and instructions regarding what to show and when during the demo. Have a play around, change some dialogue, maybe try adding an event if you want, then save and build the demo again.

Once you have finished playing around with the demo and want to start on your own project proper, you will need to edit the following files:

1) /source/main.lua. Here you define which scenes you will be using by importing them, as you can see near the top of the file where it says:

import 'scenes/PlayVNDemo'

Change this to the name of the scene you want to import, or if you will be using multiple, add them all here one after another.

You will also need to change the section at the bottom of the file where it says Noble.new(PlayVNDemo... etc to be the name of your first scene instead of PlayVNDemo.

2) /source/scenes/PlayVNDemo.lua. You will probably want to either rename this or make a copy and rename it. Once you have renamed it, you will want to use ctrl+h to find and replace all instances of 'PlayVNDemo' with the name of your new scene. For ease of use I recommend setting this the same as the file name. The only other two lines in here you need to pay attention to are:

i) background = Graphics.image.new("assets/images/basic_room")

which defines the default starting background. Just make sure this is pointing to a real background image or it will throw an error.

ii) line = deepcopy(db["title1"])

which defines the name of the first event that should load. If yours is not called 'title1', then just change that here or it will throw an error.

3) /source/assets/json/PlayVNDemo.json. You should make a copy of this, or a new .json file, which matches the name of your new scene file (but with .json instead of .lua, obviously). This is where you are going to be spending 99% of your time. This is, for all intents and purposes, the game, everything else is just the engine. Take a look at how PlayVNDemo.json is set up, and read the 'features' section of this documentation to learn all the things you can do in this file to make a great game.

4) /source/libraries/playvn/customfunctions.lua. This is where, if you want to, you can define custom functions for your game. By default, two are present, 'setconstants' and 'onPressB'.

'setconstants' as it is set up in the demo demonstrates how to create variables to reduce file size and make creating your game easier, however it is entirely optional and can be removed.

'onPressB' is *NOT OPTIONAL*, the game will look for it when you press the B button in the game. By default it is set to go to an inventory screen and return when B is pressed a second time, but this can be changed to whatever you want, or disabled by simply removing everything between the lines 'function onPressB()' and the final 'end' line. If your inventory in your json file is not called 'inventory' you will want to alter this. During development it might be best to disable it and re-insert it later.


## Assets

In addition to code, you will need to add images, music, and sound effects. Images should be stored under /source/assets/images. Sound effects and music should be stored under /source/assets/sounds. 

You can also change the font, should you wish. To do so, add the font to the /source/assets/fonts/ folder and edit the commented out line in the file you made in step 2 of 'first steps' above which looks like this:

-- newfont = Graphics.font.new("oldsource/fonts/REPLACETHISPART")

Remove the two dashes at the front and replace the REPLACETHISPART section with the name of your .fnt file, but without the .fnt extension.

PLEASE NOTE: I have not done *ANY* testing with this function and it may produce unpredictable results.


## Features

After setup, the entire system runs off a single .json file (with an optional additional file for custom lua code) which acts as the database for the engine.

Each entry in the .json array can contain any number of the following fields:


### eventtype

This can be one of four types: dialogue, menu, scene, and inspect.

- ‘dialogue’ is going to be your most used eventtype. It does not actually require any dialogue to be present, but it is essentially any segment where there is no menu, no transition, and you are not interacting with the scene. If you populate the ‘content’ field with text it will print it on screen in the dialogue box.

- ‘menu’ presents the user with a centered vertical menu with the options you pass in the ‘content’ field. These options are separated by a |, for example ‘option 1|option 2|option 3’. These will correspond to entries in the ‘goto’ field, for example ‘1|2|3’. You must have the same number of entries in each or the game will probably crash.

- ‘scene’ is used to transition from one Noble Engine scene to another. The new scene is determined by the field ‘newscene’. If this is not set, it defaults to the current scene which enables the transitions to be used to move between PlayVN entries.

- ‘inspect’ allows the player to inspect the background, with interactive areas defined in the ‘locations’ section. See the locations section for full details. Please note that you will need to remove any ‘peeps’ manually by setting them to “” or they will remain on screen. Unless you want the player to still see them of course.

---
### content

The content section’s function depends on which eventtype is being used. 

When ‘dialogue’ is being used, the text that is to be displayed in the dialogue box goes here. If nothing is entered, no dialogue box will appear. PLEASE NOTE: There is not currently any function to handle text overflow. If you put too much text it will simply overflow the text box after the second line. Please check your dialogue and see how much space it fills and manually adjust it. I know this isn’t ideal. Sorry.

If ‘menu’ is being used, it contains the text of the menu entries. 

It is not used in scene and inspect events and should be left out.

---
### goto

This field defines where the user should be sent after the current entry. 

For a ‘dialogue’ entry, once the text has finished being displayed, the user pressing A will send them to the entry in the ‘goto’ field. 

For a ‘menu’ entry, it defines where the user should be sent after selecting the corresponding entry in the ‘content’ section.

For a ‘scene’ it defines where the user should be sent after the transition completes.

It is not used for ‘inspect’ entries and should be left out.

---
### disablebuttons

This option disables the user from pressing any buttons until the next entry loads. Use this for animations, speech etc or anything else you don’t want the user to skip. Must be used in conjunction with the ‘autoadvance’ option or you’ll have the user stuck there forever! The only value for this field is ‘yes’.

---
### autoadvance

Automatically advances the user to the entry in the ‘goto’ field after the number of frames defined in this entry, as if they had pressed A.

---
### sfx

This will play a sound effect. The folder for sound effects is set as ‘assets/sounds’ and you should just put the name of the sound effect, not the file extension or folder. For example sfx:’holdit’ will play assets/sounds/holdit.mp3.

Sound effects will play one time.

---
### bgm

This will play a .mp3 file. The folder for music is set as ‘assets/sounds’ and you should just put the name of the file, not the file extension or folder. For example bgm:’intense’ will play assets/sounds/intense.mp3.

Music will play on repeat until encountering a new ‘bgm’ or ‘bgmidi’ entry. If the ‘bgm’ field on an entry is blank, playback will stop.

---
### bgmidi

This will play a .midi file. The folder for music is set as ‘assets/sounds’ and you do need to put the full file name, including the extension.

Music will play on repeat until encountering a new ‘bgmidi’ or ‘bgm’ entry. If the ‘bgmidi’ field on an entry is blank, playback will stop.

Currently this uses the same instruments for every song. I don’t know enough about midi instruments to change this at the moment. If anyone knows of a good tutorial or something for this please let me know!

---
### transition

This is used only during a ‘scene’ event to determine which of the Noble Engine transitions to use, with each corresponding exactly to a Noble Engine transition.

Listed here for ease of reference the options are: 

CUT
CROSS_DISSOLVE
DIP_TO_WHITE
DIP_WIDGET_SATCHEL
DIP_METRO_NEXUS
SLIDE_OFF_LEFT
SLIDE_OFF_RIGHT
SLIDE_OFF_UP
SLIDE_OFF_DOWN
DIP_TO_BLACK

If transition is not set or a value other than those presented is entered, it will default to DIP_TO_BLACK.

---
### duration

This is used only during a ‘scene’ event to determine how long in seconds the transition should last. A value of ‘1.0’ will last 1 second, for example.

---
### nosave

By default PlayVN saves its current state every time a new entry is loaded. This is sometimes undesirable and can cause problems (E.G, you don’t want the game to save before the option to load has been presented!) so adding ‘nosave’ to these entries prevents this. The only value for nosave is ‘yes’.

---
### background

This field populates the background of the scene with a png file. These should be full 400x240 size png files. By default the images folder is ‘assets/images’ and you don’t have to include the file extension, so for example background:’castle’ would set ‘assets/images/castle.png’ as the background.

The background can also be animated. Images are separated by a | and each image must also have a frame count, separated from it by a colon. So for example:

background:’castle1:10|castle2:10’

would alternate between displaying assets/images/castle1.png for 10 frames then assets/images/castle2.png for 10 frames.

The background or animated background remains until replaced. It cannot be blank, so you will need to add a blank .png file in that instance.

---
### overlay

This field overlays an image over in the foreground of the scene with a .png file. These can be any size. By default the images folder is ‘assets/images’ and you don’t have to include the file extension, so for example overlay:’holdit’ would set ‘assets/images/holdit.png’ as the overlay.

The overlay defaults to being positioned at the very top left of the screen, but can be repositioned by adding the required x and y co-ordinates you want to be the top left corner of the overlay after the name of the overlay, separated by colons. For example:

overlay: ‘holdit:20:20’

would display assets/images/holdit.png at x20 y20.

The overlay can also be animated. Images are separated by a | and each image must also have a frame count, separated from it by a colon placed after the co-ordinates. So for example:

overlay:’holdit1:20:20:10|holdit2:40:40:20’

would alternate between displaying assets/images/holdit1.png for 10 frames at x20 y20, then assets/images/holdit2.png for 20 frames at x40 y40.

The overlay is removed on moving to the next entry.

---
### loadgame

This loads the game. Best used as an option on the title screen leading to an entry set up as follows:

"loadgame": {
    "eventtype": "dialogue",
    "autoadvance": "1",
    "nosave": "yes",
    "loadgame": "yes"
   },

This will load the position the player left the game at and resume from there. It only accepts the value ‘yes’.

---
### leftpeep, middlepeep, rightpeep

These three fields do the same thing for three different positions on the screen, they put an image over the top of the foreground, normally to be used as a character sprite, or ‘peep’. 

‘leftpeep’ positions the image at the far left of the screen, with the left edge of the image touching the left side of the screen. 

‘rightpeep’ does the opposite, touching the right side with the right side of the image. 

‘middlepeep’ places the middle of the image in the middle of the screen.

By default the images folder is ‘assets/images’ and you don’t have to include the file extension, so for example leftpeep:’bob’ would set ‘assets/images/bob.png’ as the left peep.

The peeps can also be animated. Images are separated by a | and each image must also have a frame count, separated from it by a colon. So for example:

background:’bob1:10|bob2:10’

would alternate between displaying assets/images/bob1.png for 10 frames then assets/images/bob2.png for 10 frames.

Peeps remain until replaced or removed by putting an entry with the corresponding peep as a blank. For example:

leftpeep: “”

would remove the left peep.

---
### leftpeeptalking, middlepeeptalking, rightpeeptalking

These fields are used to display a ‘talking’ animation whilst the dialogue of an entry is playing. These work exactly the same as the peep field, simply replacing that field until the dialogue has finished writing out on the screen.

Unlike the previous fields, these fields need to be included every time they are to be used. This is to prevent characters ‘speaking’ when it is another peep’s turn to talk.

---
### whichpeep

To help the user identify which character is speaking in a scene, you can use this field to make that character sprite ‘jump up’ 10 pixels for the duration of an entry.

This field only accepts the values ‘leftpeep’, ‘middlepeep’, and ‘rightpeep’.

This field needs to be included on every entry you want that peep to be highlighted. When not included, the peep will pop back down. Only one peep can pop up at a time.

---
### whospeaking

This field populates the little label over the dialogue box signifying who is speaking a particular piece of dialogue. This needs to be added to each entry in which you want it to appear. As with dialogue there is no overflow for this, but really how long do you need your character names to be?

---
### locations

This field is used solely by the ‘inspect’ event type and defines locations on the screen which the user can interact with.

Each location is square (so if you want other shapes you will have to make them out of lots of squares) and is defined in the following manner: The X co-ordinate of the top left corner of the square, the y co-ordinate of the top left corner of the square, the width of the square, the height of the square, the ID of the entry to send the user to upon selecting to inspect the area. These are separated by colons, and each location is separated by a |.

For example: 

12:30:68:68:inventorytrickle|83:30:68:68:inventorysparky|234:30:48:48:inventoryshell

This defines three locations that can be inspected. The first two are 68px square, the third is 48px square. The first is at x12 y30, the second x83 y30, and the third at x234 y30. The three ‘inventory’ words are the links to the corresponding entries. This makes up part of an inventory screen.

---
### newscene

This field is used exclusively with the ‘scene’ event type and determines which Noble Engine scene you are switching to. If this is not included the scene defaults to the name of the scene as set in the main file, as described in the installation instructions.

---
### setvariables

A very useful function of PlayVN is its use of variables. Any field can have its value replaced entirely or in part by one or more variables. These can be defined in the ‘customfunctions.lua’ file, but can also be defined and changed on the fly as a field on an entry. Variables are used by putting their variablename in a field, but preceding it by \~1 and following it by 1\~. For example:

\~1myvariable1\~

For example, a character called Lox has a laughing animation for when he is speaking. The entry for this animation is as follows:

leftpeeptalking: "lox_laughing_talking:2|lox_laughing_talking_2:1|lox_laughing_2:1|lox_laughing:2|lox_laughing_talking_2:2|lox_laughing_talking:1|lox_laughing:1|lox_laughing_2:2"

That’s pretty long! Especially if we want to use it several times! 
So instead we define the variable ‘loxlaughing’ as "lox_laughing_talking:2|lox_laughing_talking_2:1|lox_laughing_2:1|lox_laughing:2|lox_laughing_talking_2:2|lox_laughing_talking:1|lox_laughing:1|lox_laughing_2:2". 

This reduces it to: leftpeeptalking: “\~1loxlaughing1\~”

Much shorter! We can also use this to open up different menu options. For example, if we have a variable called menu1 and set it to the value of the entry the menu is in at the start of the game, and we place that variable in the goto value of one of our entries, then when the player first gets to that entry they will be directed to the first version of the menu. However, after doing whatever is required to open up the second part of the menu, asking a particular question, for example, we can alter the variable and change where the entry goto value takes us, redirecting us to a different, expanded menu.

That might be hard to follow in text form, so here is a more spread out example.

A guard asks Bob for a password. As Bob has not learned the password yet, the variable bobpasswordknown is set to ‘50’, as it was set in the customfunctions.lua file.

The ‘goto’ field of the dialogue entry for the guard asking for the password is set as ‘\~1bobpasswordknown1\~’, so this is changed to 50 when the entry is processed, taking the user to entry 50.

Bob is presented with entry 50, wherein he tells the guard he does not know the password and is told to leave.

Later Bob meets Steve and Steve tells bob the password. On being told the password the field ‘setvariables’ is set to 60 as follows:

setvariables: ‘bobpasswordknown:60’

Now when Bob goes to talk to the guard he is redirected to entry 60, not 50, whereby he is able to give the guard the password.

Multiple variables can be set in this fashion at the same time by separating them using a |. For example:

setvariables: menu1:0|menu2:0|playername:Gavin

As noted, variables like this can be used for any field, and multiple variables can be used in one field. However, the number after the \~ at the start of the variable name and before the \~ at the end of the variable name must increase by one for each variable used in one field.

An example entry to demonstrate this:

  "7": {
     "eventtype": "dialogue",
     "content": "Hello there \~1playername1\~. I’ve never met anyone from \~2hometown2\~ before.",
     "whospeaking": "Trickle",
     "middlepeep": "\~1trickleforwards1\~",
     "middlepeeptalking": "\~1trickleforwardst1\~",
     "background": "basic_room",
     "goto": "9",
   },

Note how the number increases when two variables are used in the content line, but later entries start from 1 again.

---
### function, functionvariables

Meant primarily for advanced users, these fields allow you to call custom functions when the entry is loaded. For example:

function: setConstants

will call the function setConstants() when the entry loads. Custom functions can be defined in the customfunctions.lua file. 

Two example custom functions are included and may also be of interest to less advanced users:


- setConstants()

This function shows how to set variables using a function. This is useful for, for example, predefining often-reused animations.


- OnPressB()

This function determines what should happen when the user presses the B button. The default one accesses the character’s inventory then returns them to the game on a second press. Should this not be required, removing the contents of this section will disable the b button.


You can also use the field ‘functionvariables’ to pass variables to a function. For example:

function: “customFunction1”
functionvariables: “boom,headshot”

will call the function ‘customFunction1’ and pass it the strings ‘boom’ and ‘headshot’ as the first and second variables. You can combine this with PlayVN variables by doing the following:

function: “customFunction1”
functionvariables: “boom,\~1headshotvalue1\~”

which will call the function ‘customFunction1’ and pass the string ‘boom’ as the first variable, but set the second variable as whatever the current value of the variable ‘headshotvalue’ is.
