---@meta utils

local logging = require("logging")

--##

---@class utils
local g4l = {}

function g4l.log(toLog)
    logging.info("[git4lönn] "..tostring(toLog))
end

return g4l