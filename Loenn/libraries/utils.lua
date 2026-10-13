---@meta utils

local logging = require("logging")

--##

---@class utils
local g4l = {}

function g4l.log(toLog)
    logging.info("[git4lönn] "..tostring(toLog))
end

function g4l.stripPrefix(str, prefix)
    if str:sub(1, #prefix) == prefix then
        return true, str:sub(#prefix + 1)
    end

    return false
end

return g4l