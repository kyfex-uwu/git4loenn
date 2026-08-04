---@meta logging

---@class logging
local logging = {}

---Logs with "ERROR" status.
---@param message string
---@param filename string?
---@param force boolean?
function logging.error(message, filename, force) end

---Logs with "INFO" status.
---@param message string
---@param filename string?
---@param force boolean?
function logging.info(message, filename, force) end

return logging