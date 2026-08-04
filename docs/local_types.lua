---@meta LocalTypes

---@class MapDataTable : table
---@field data MapData
---@field package string
---@field header string


---@class DataItem : table
---@field __children DataItem[]

---@class MapDataItem : DataItem
---@field __name string

---@class MapData : MapDataItem
---@field _package string
