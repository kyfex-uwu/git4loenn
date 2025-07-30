local fileLocations = require("file_locations")
local languageRegistry = require("language_registry")
local mods = require("mods")
local uiElements = require("ui.elements")
local form = require("ui.forms.form")
local notification = require("ui.notification")
local widgetUtils = require("ui.widgets.utils")
local windows = require("ui.windows")
local windowPersister = require("ui.window_position_persister")
local filesystem = require("utils.filesystem")

local g4l = mods.requireFromPlugin("libraries.utils")

--##

local newCampaign = {}

local holder = uiElements.group({})
windows.windowHandlers["git4loenn_newCampaign"] = holder

function newCampaign.open()
	local language = languageRegistry.getLanguage()

	local data = {
		campaignName = "",
		mapName = "",
	}
    local windowContent = uiElements.column({
    	uiElements.row({
	        uiElements.label(tostring(language.ui.git4loenn.newCampaign.name)),
	        uiElements.field(data.cloneFrom, function(_, text)
	        	data.cloneFrom = text
	    	end),
	        uiElements.label(tostring(language.ui.git4loenn.newCampaign.repo_name)),
	        uiElements.field(data.cloneFrom, function(_, text)
	        	data.repoName = text
	    	end),
	        uiElements.button(tostring(language.ui.git4loenn.newCampaign.clone), function()
	        	if os.execute(string.format("git clone %s %s", data.cloneFrom, 
	        		filesystem.joinpath(fileLocations.getCelesteDir(), "Mods", data.repoName))) ~= 0 then
	        		notification.notify("Could not clone repository")
        		else
	        		notification.notify("Successfully cloned repository")
    			end
        	end),
	    }),
    }):with({
        style = {
            spacing = 8,
            padding = 8
        }
    })

    local window = uiElements.window(tostring(language.ui.git4loenn.newCampaign.title), windowContent):with({
        height = 640,
        width = 850
    })
    windowContent:layout()
    windowPersister.trackWindow("git4loenn_cloneCampaign", window)
    holder.parent:addChild(window)
    widgetUtils.addWindowCloseButton(window, windowPersister.getWindowCloseCallback("git4loenn_newCampaign"))
    widgetUtils.preventOutOfBoundsMovement(window)
    form.prepareScrollableWindow(window)

    return window
end

return newCampaign