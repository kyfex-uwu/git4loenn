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

    ---@type LoennDataTable
    local loennData = {
        header = mapData.header,
        package = mapData.package,
        data = mapcoder.decodeData(mapData)
    }

    coroutine.yield("update", loennData.data)

    return loennData.data
end

---@param mapData MapDataTable
---@return LoennData
function mapcoder.decodeData(mapData)
    ---@type LoennData
    local newData = {
        _package = mapData.package,
        __name = mapData.data.__name,
        __children = mapData.data.__children
    }

    return newData
end

--##

---@generic T
---@param v T
---@return T
local function identity(v) return v end

---Transforms Loenn map data into json map data
---@param data LoennData Loenn's map data
---@return MapData # JSON map data
---@return DataItem[] # JSON map data for levels
function mapcoder.transformData(data)
    coroutine.yield()

    ---@type MapData
    local mapData = {
        _package = data._package,
        __name = data.__name,
    }
    ---@type DataItem[]
    local levelsData = {}

    if #(data.__children or {}) ~= 0 then
        mapData.__children = {}

        for i, child in ipairs(data.__children or {}) do
            if child.__name == "levels" then
                mapData.__levels = {}

                for j, level in ipairs(child.__children) do
                    local levelData = mapcoder.transform(level)
                    table.insert(levelsData, levelData)
                    table.insert(mapData.__levels, data._package.."."..levelData["name"])
                end
            else
                table.insert(mapData.__children, mapcoder.transform(child))
            end
        end
    end

    return mapData, levelsData
end

---Transforms Loenn map data item into json map data
---@param data LoennItem Loenn's map data item
---@return DataItem # JSON map data item
function mapcoder.transform(data)
    coroutine.yield()

    ---@type DataItem
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
    local mapData, levelsData = mapcoder.transformData(data)
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