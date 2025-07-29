local languageRegistry = require("language_registry")
local logging = require("logging")
local mods = require("mods")
local uiElements = require("ui.elements")
local form = require("ui.forms.form")
local widgetUtils = require("ui.widgets.utils")
local windows = require("ui.windows")
local windowPersister = require("ui.window_position_persister")

local uiRoot = require("ui.ui_root")

local settings = mods.getModSettings("git4loenn")

local g4l = {}

--##

function g4l.log(toLog)
    logging.info("[git4lönn] "..tostring(toLog))
end

--##

local g4lSettingsHolder = uiElements.group({})
windows.windowHandlers["git4loenn_settings"] = g4lSettingsHolder
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

    local window = uiElements.window(tostring(language.ui.git4loenn_settings.title), windowContent)

    windowContent:layout()

    windowPersister.trackWindow("git4loenn_settingsWindow", window)

    g4lSettingsHolder.parent:addChild(window)

    widgetUtils.addWindowCloseButton(window, windowPersister.getWindowCloseCallback("git4loenn_settingsWindow"))
    widgetUtils.preventOutOfBoundsMovement(window)
    form.prepareScrollableWindow(window)

    return window
end

local menubar = require("ui.menubar").menubar
local fileMenu = $(menubar):find(menu -> menu[1] == "file")[2]
if not $(fileMenu):find(item -> item[1] == "git4loenn_fileMenu") then
    table.insert(fileMenu,{
        "git4loenn_fileMenu",
        {
            {"git4loenn_newCampaign"},
            {"git4loenn_openCampaign"},
            {"git4loenn_settings", openSettings},
        }
    })
end

g4l.log("Loaded")

return g4l