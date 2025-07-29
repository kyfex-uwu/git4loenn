local languageRegistry = require("language_registry")
local mods = require("mods")
local uiElements = require("ui.elements")
local form = require("ui.forms.form")
local widgetUtils = require("ui.widgets.utils")
local windows = require("ui.windows")
local windowPersister = require("ui.window_position_persister")

local settings = mods.getModSettings("git4loenn")
local cloneCampaign = mods.requireFromPlugin("libraries.cloneCampaign")
local g4l = mods.requireFromPlugin("libraries.utils")

--##

local settingsHolder = uiElements.group({})
windows.windowHandlers["git4loenn_settings"] = settingsHolder
function openSettings()
    local language = languageRegistry.getLanguage()
    local settingsTemp = "gorp gorp gorp gorp gorp"

    local windowContent = uiElements.column({
        uiElements.label(settingsTemp),
        uiElements.label(settingsTemp),
        uiElements.label(settingsTemp),
    }):with({
        style = {
            spacing = 8,
            padding = 8
        }
    })

    local window = uiElements.window(tostring(language.ui.git4loenn.settings.title), windowContent)
    windowContent:layout()
    windowPersister.trackWindow("git4loenn_settings", window)
    settingsHolder.parent:addChild(window)
    widgetUtils.addWindowCloseButton(window, windowPersister.getWindowCloseCallback("git4loenn_settings"))
    widgetUtils.preventOutOfBoundsMovement(window)
    form.prepareScrollableWindow(window)

    return window
end

local menubar = require("ui.menubar").menubar
local fileMenu = $(menubar):find(menu -> menu[1] == "file")[2]
for i,v in ipairs(fileMenu) do
    if v[1] == "git4loenn_fileMenu" then
        table.remove(fileMenu, i)
        break
    end
end
table.insert(fileMenu,{
    "git4loenn_fileMenu",
    {
        {"git4loenn_newCampaign"},
        {"git4loenn_openCampaign"},
        {"git4loenn_cloneCampaign", cloneCampaign.open},
        {},
        {"git4loenn_settings", openSettings},
    }
})

g4l.log("Loaded")

return g4l