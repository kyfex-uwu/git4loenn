local logging = require("logging")
local mods = require("mods")
local settings = mods.getModSettings("git4loenn")

local g4l = {}

--##

function g4l.log(toLog)
    logging.info("[git4lönn] "..tostring(toLog))
end

local menubar = require("ui.menubar").menubar
local fileMenu = $(menubar):find(menu -> menu[1] == "file")[2]
if not $(fileMenu):find(item -> item[1] == "git4loenn_fileMenu") then
    table.insert(fileMenu,{
        "git4loenn_fileMenu",
        {
            {"git4loenn_newProject"},
            {"git4loenn_openProject"},
        }
    })
end

g4l.log("Loaded")

return g4l