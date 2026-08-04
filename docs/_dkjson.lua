---@meta lib.dkjson

---@class dkjson
local dkjson = {}

---@class EncodeState
---@field buffer table?
---@field bufferlen integer?
---@field indent boolean?
---@field keyorder table?
---@field level integer?
---@field tables table?
---@field exception (fun(reason: string, value: unknown, state: EncodeState, defaultMessage: string): string)?

---@param value any
---@param state EncodeState
---@return string
function dkjson.encode (value, state) end

---@param str string
---@param pos integer
---@param nullval any
---@param ... unknown
---@return any
function dkjson.decode (str, pos, nullval, ...) end

return dkjson