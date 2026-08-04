---@meta logging

---@class logging
local logging = {}

---Logs with "ERROR" status.
---@param message string
---@param filename string?
---@param force boolean?
function logging.error(message, filename, force) end

return logging