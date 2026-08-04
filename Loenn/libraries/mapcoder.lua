---@module "dkjson"
local json = require("lib.dkjson")
---@module "logging"
local logging = require("logging")

local mapcoder = {}

--todo: fix this
function mapcoder.decodeFile(path, header)
    header = header or "CELESTE MAP"

    local reader = io.open(path, "rb")

    if not reader then
        return false, "File not found"
    end

    local mapData = json.decode(reader:read("*all"))
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

--todo: fix this
function mapcoder.encodeFile(path, data, header)
    local content = json.encode({
        header=header or "CELESTE MAP",
        package=data._package or "",

        data=mapcoder.transform(data)
    },{
        indent=true,
        exception=function(reason, value, state, defaultMessage)
            logging.error("[JsonMaps] saving to json error: "..reason)
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