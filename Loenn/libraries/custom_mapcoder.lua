---@meta custom_mapcoder

local json = require("lib.dkjson")
local logging = require("logging")
local lfs = require("lib.lfs_ffi")

---@class custom_mapcoder
local mapcoder = {}

---Reads a .meta.g4l file and outputs the stored map's data
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

    ---@type LoennData
    local loennData = {
        _package = mapData.package,
        __name = mapData.data.__name,
        __children = mapData.data.__children --[[@as (LoennItem[])]]
    }

    if #(mapData.data.__levels or {}) ~= 0 then
        ---@type LoennItem
        local levelsData = {
            __name = "levels",
            __children = {}
        }

        for i, levelName in ipairs(mapData.data.__levels) do
            local levelData, message = mapcoder.decodeLevel(levelName)
            if not levelData then
                -- log error
            else
                table.insert(levelsData.__children, levelData)
            end
        end

        table.insert(loennData.__children, 1, levelsData)
    end

    coroutine.yield("update", loennData)

    return loennData
end

---Reads a .g4l file and outputs the map's level data
---@param levelName string
---@return LoennItem | false # Level Data if successful, false otherwise
---@return string? # Error message if failure, nil otherwise
function mapcoder.decodeLevel(levelName)
    local levelPath = "" --TODO: sync with how levels are stored

    local reader = io.open(levelPath, "rb")
    if not reader then
        return false, "File not found"
    end

    local levelData = json.decode(reader:read("*all")) --[[@as LoennItem]]
    reader:close()

    if levelData["name"] ~= levelName then
        return false, "Level name does not match filename"
    end
    
    return levelData
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
            if child.__name == "levels" and #(child.__children or {}) ~=0 then
                mapData.__levels = {}

                for j, level in ipairs(child.__children) do
                    local levelData = mapcoder.transform(level)
                    table.insert(levelsData, levelData)
                    table.insert(mapData.__levels, levelData["name"])
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

---Save a map's data as a .meta.g4l file with its .g4l level files
---@param savingPath string Path to save the level at (has .saving at the end)
---@param data LoennData
---@param header string
function mapcoder.encodeFile(savingPath, data, header)
    local rootPath = string.sub(savingPath,0,-12)
    local mapData, levelsData = mapcoder.transformData(data)

    mapcoder.saveFile({
        header=header or "CELESTE MAP",
        package=data._package or "",
        data=mapData
    }, rootPath .. ".meta.g4l")

    lfs.mkdir(rootPath)
    for _, levelData in ipairs(levelsData) do
        mapcoder.saveFile(levelData, rootPath .. "/" .. levelData["name"] .. ".room.g4l")
    end

    coroutine.yield()
end

function mapcoder.saveFile(value, path)
    local content = json.encode(
        value,{
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
end

return mapcoder