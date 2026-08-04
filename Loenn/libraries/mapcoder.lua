---@meta mapcoder

local json = require("lib.dkjson")
local logging = require("logging")

---@class mapcoder
local mapcoder = {}

---Reads a .json file and outputs the stored map's data
---TODO: Update to .g4l
---@param path string
---@param header string
---@return LoennData | false # Map data in case of success, else false
---@return string? # The error message in case of failure, else nil
function mapcoder.decodeFile(path, header)
    header = header or "CELESTE MAP"

    local reader = io.open(path, "rb")

    if not reader then
        return false, "File not found"
    end

    local mapData = json.decode(reader:read("*all")) --[[@as MapDataTable]]
    reader:close()

    if mapData.header == nil then
        return false, "Invalid Celeste map file"
    end

    mapData.data._package = mapData.package

    coroutine.yield("update", mapData.data)

    return mapData.data
end

--##

---@generic T
---@param v T
---@return T
local function identity(v) return v end

---Transform's Loenn map data into json map data
---@param data LoennItem Loenn's map data item
---@return DataItem # JSON map data item
function mapcoder.transform(data)
    coroutine.yield()

    local toReturn = {}

    for attr, value in pairs(data) do
        if attr ~= "__children" then
            toReturn[attr]=(type(value)=="table" and mapcoder.transform or identity)(value)
        end
    end

    if #(data.__children or {}) ~= 0 then
        toReturn.__children = {}

        for i, child in ipairs(data.__children or {}) do
            table.insert(toReturn.__children, mapcoder.transform(child))
        end
    end

    return toReturn
end

---Save a map's data as a .json file
---TODO: Update to .g4l
---@param path string
---@param data LoennData
---@param header string
function mapcoder.encodeFile(path, data, header)
    local mapData = mapcoder.transform(data)
    local content = json.encode({
        header=header or "CELESTE MAP",
        package=data._package or "",
        data=mapData
    },{
        indent=true,
        exception=function(reason, value, state, defaultMessage)
            logging.error("[git4lönn] saving to g4l error: "..reason)
            return ""
        end,
    })

    local fh = io.open(path, "wb")

    if fh then
        fh:write(content)
        fh:close()
    end

    coroutine.yield()
end

return mapcoder