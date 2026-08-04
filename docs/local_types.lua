---@meta LocalTypes

---@class JsonDataTable : table
---@field package string
---@field header string


---@class LoennDataTable : JsonDataTable
---@field data LoennData


---@class LoennItem : table
---@field __children LoennItem[]?
---@field __name string

---@class LoennData : LoennItem
---@field _package string?


---@class MapDataTable : JsonDataTable
---@field data MapData


---@class DataItem : table
---@field __children DataItem[]?
---@field __name string?

---@class MapData : DataItem
---@field _package string
---@field __levels string[]?
