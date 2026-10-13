---@meta utils

local logging = require("logging")

--##

---@class utils
local g4l = {}

function g4l.log(toLog)
    logging.info("[git4lönn] "..tostring(toLog))
end

---Check if string starts with prefix, and remove it
---@param str string the base string
---@param prefix string the prefix to check and remove
---@return boolean # whether the string starts with the prefix
---@return string? # the remaining string, or nil if prefix check fails
function g4l.stripPrefix(str, prefix)
    if str:sub(1, #prefix) == prefix then
        return true, str:sub(#prefix + 1)
    end

    return false
end

return g4l