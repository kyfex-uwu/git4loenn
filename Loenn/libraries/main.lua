local languageRegistry = require("language_registry")
local mods = require("mods")
local uiElements = require("ui.elements")
local form = require("ui.forms.form")
local widgetUtils = require("ui.widgets.utils")
local windows = require("ui.windows")
local windowPersister = require("ui.window_position_persister")
local mapcoder = require("mapcoder")
local loaded_state = require("loaded_state")
local filesystem = require("utils.filesystem")
local fileLocations = require("file_locations")

local settings = mods.getModSettings("git4loenn")
---@module "CloneCampaign"
local cloneCampaign = mods.requireFromPlugin("libraries.cloneCampaign")
---@module "utils"
local g4l = mods.requireFromPlugin("libraries.utils")
---@module "mapcoder"
local custom_mapcoder = mods.requireFromPlugin("libraries.mapcoder")

--##

local old_save = mapcoder.encodeFile
local old_load = mapcoder.decodeFile
mapcoder.encodeFile = function(path, data, header)
	if true then --todo: if map is g4l map
        custom_mapcoder.encodeFile(path..".g4l", data, header)
    end

	return old_save(path, data, header)
end
mapcoder.decodeFile = function(path, header)
	if path:sub(#path-8) == ".meta.g4l" then
        return custom_mapcoder.decodeFile(path, header)
    end

	return old_load(path, header)
end

function openLevel()
    local targetDirectory = fileLocations.getCelesteDir()

    if loaded_state.filename and loaded_state.filename:sub(#loaded_state.filename-3) == ".g4l" and filesystem.isDirectory(loaded_state.filename) then
        targetDirectory = filesystem.dirname(loaded_state.filename)
    end

    filesystem.openDialog(targetDirectory, "meta.g4l", loaded_state.loadFile)
end

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
---@diagnostic disable-next-line: undefined-global, exp-in-action, unknown-symbol, miss-exp
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
        {"git4loenn_openLevel", openLevel},
        {"git4loenn_newCampaign"},
        {"git4loenn_cloneCampaign", cloneCampaign.open},
        {},
        {"git4loenn_settings", openSettings},
    }
})

g4l.log("Loaded")

return g4l