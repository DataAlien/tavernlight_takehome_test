-- Constants
local SHIFT_PIXELS = 8 
local SHIFT_PIXELS_DELAY_MS = 70
local PAD_LEFT = 12
local PAD_RIGHT = 70
local PAD_TOP = 50
local PAD_BOTTOM = 20

-- UI
local window = nil
local button = nil
local menuButton = nil
local updateButtonEvent = nil 

-- automatically called by OTC on module load
function init()
	-- Create the window using the otui file references
	window = g_ui.displayUI('tavernlight_jumpgame')
	button = window:getChildById('jumpButton')

	-- Adding toggle button to toolbar, uses default icon. Chose particles since I haven't seen it used elsewhere.
	menuButton = modules.client_topmenu.addLeftButton('menuButton', tr('tavernlight_jumpgame'), '/images/topbuttons/particles', toggle)

	-- Make sure it's hidden by default
	window:hide()
end

-- Button will "jump" to a new position, at a random position on the window's y axis.
function newButtonPosition()
	local newPos = window:getPosition()
	newPos.x = newPos.x + window:getWidth() - PAD_RIGHT
	newPos.y = newPos.y + math.random(PAD_BOTTOM, (window:getHeight() - PAD_TOP))
	button:setPosition(newPos)
end

-- Event to move the button. Shifts over by SHIFT_PIXELS for every SHIFT_PIXELS_DELAY_MS to create the jitter effect from the video.
function updateButton()
	local newPos = button:getPosition()
	newPos.x = newPos.x - SHIFT_PIXELS
	button:setPosition(newPos)

	-- Selects a new location via newButtonPosition if the button moves itself out of bounds.
	if newPos.x < window:getPosition().x + PAD_LEFT then
		newButtonPosition()
	end
end

-- Used to initiate our updateButton event. Sets a new Jump button position before doing so.
function startMoving()
	newButtonPosition()
	updateButtonEvent = cycleEvent(updateButton, SHIFT_PIXELS_DELAY_MS)
end

-- Remove and clear the updateButton event.
function stopMoving()
	if updateButtonEvent then
		removeEvent(updateButtonEvent)
		updateButtonEvent = nil
	end
end

-- Called when the OTClient toggle button we made in init() is clicked.
function toggle()
	if window:isVisible() then
		hide()
	else
		show()
	end
end

function show()
	window:show()
	window:raise()
	window:focus()
	startMoving()
end

function hide()
	window:hide()
	stopMoving()
end

function terminate()
	hide()
end