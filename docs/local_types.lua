---@meta LocalTypes

---@class MapDataTable : table
---@field data LoennData
---@field package string
---@field header string


---@class LoennItem : table
---@field __children LoennItem[]?

---@class LoennData : LoennItem
---@field _package string?


---@class DataItem : table
---@field __children DataItem[]?
---@field __name string?
---@field _package string?
