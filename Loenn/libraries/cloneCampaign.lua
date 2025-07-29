local languageRegistry = require("language_registry")
local uiElements = require("ui.elements")
local form = require("ui.forms.form")
local widgetUtils = require("ui.widgets.utils")
local windows = require("ui.windows")
local windowPersister = require("ui.window_position_persister")

local cloneCampaign = {}

local holder = uiElements.group({})
windows.windowHandlers["git4loenn_cloneCampaign"] = holder

function cloneCampaign.open()
	local language = languageRegistry.getLanguage()

    local windowContent = uiElements.column({
    	uiElements.row({
	        uiElements.label(tostring(language.ui.git4loenn.cloneCampaign.repo_uri)),
	        uiElements.field("", function(_, text) end),
	        uiElements.button(tostring(language.ui.git4loenn.cloneCampaign.clone), function()
	        	--os.execute("touch /home/abby/Documents/Backups/test") --this should work!
        	end),
	    }),
    }):with({
        style = {
            spacing = 8,
            padding = 8
        }
    })

    local window = uiElements.window(tostring(language.ui.git4loenn.cloneCampaign.title), windowContent):with({
        height = 640,
        width = 850
    })
    windowContent:layout()
    windowPersister.trackWindow("git4loenn_cloneCampaign", window)
    holder.parent:addChild(window)
    widgetUtils.addWindowCloseButton(window, windowPersister.getWindowCloseCallback("git4loenn_cloneCampaign"))
    widgetUtils.preventOutOfBoundsMovement(window)
    form.prepareScrollableWindow(window)

    return window
end

return cloneCampaign