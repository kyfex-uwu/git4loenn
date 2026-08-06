---@meta custom_mapcoder

local json = require("lib.dkjson")
local logging = require("logging")
local lfs = require("lib.lfs_ffi")
local mods = require("mods")
---@module "utils"
local g4l = mods.requireFromPlugin("libraries.utils")

---@class custom_mapcoder
local mapcoder = {}

mapcoder.meta_ext = "g4l"
mapcoder.room_ext = "room.g4l"

local function makeLevelPath(rootName, levelName)
    return rootName .. "/" .. levelName .. "." .. mapcoder.room_ext
end

---Reads a .g4l file and the dependent .room.g4l files and return the stored map's data
---@param path string the .g4l file path
---@param header string i unno
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

        local folder_name = string.sub(path,0,-(#mapcoder.meta_ext + 2))
        for i, levelName in ipairs(mapData.data.__levels) do
            local levelData, message = mapcoder.decodeLevel(folder_name, levelName)
            if not levelData then
                g4l.log("room loading error: " .. message)
            else
                table.insert(levelsData.__children, levelData)
            end
        end

        table.insert(loennData.__children, 1, levelsData)
    end

    coroutine.yield("update", loennData)

    return loennData
end

---Reads a .room.g4l file and outputs the map's level data
---@param folder string containing folder
---@param levelName string level name
---@return LoennItem | false # Level Data if successful, false otherwise
---@return string? # Error message if failure, nil otherwise
function mapcoder.decodeLevel(folder, levelName)
    local levelPath = makeLevelPath(folder, levelName)

    local reader = io.open(levelPath, "rb")
    if not reader then
        return false, "File " .. levelPath .." not found"
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

---Save a map's data as a .g4l file with its .room.g4l level files
---@param savingPath string Path to save the level at (has .saving at the end)
---@param data LoennData The map data
---@param header string i unno
function mapcoder.encodeFile(savingPath, data, header)
    local rootPath = string.sub(savingPath,0,-12)
    local mapData, levelsData = mapcoder.transformData(data)

    mapcoder.saveFile({
        header=header or "CELESTE MAP",
        package=data._package or "",
        data=mapData
    }, rootPath .. "." .. mapcoder.meta_ext)

    lfs.mkdir(rootPath)
    for _, levelData in ipairs(levelsData) do
        mapcoder.saveFile(levelData, makeLevelPath(rootPath, levelData["name"]))
    end

    coroutine.yield()
end

function mapcoder.saveFile(value, path)
    local content = json.encode(
        value,{
        indent = true,
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

function mapcoder.isMetaFile(path)
    return path:sub(#path-#mapcoder.meta_ext) == ("." .. mapcoder.meta_ext)
end

return mapcoder