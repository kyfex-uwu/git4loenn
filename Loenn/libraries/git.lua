---@meta git

local filesystem = require("utils.filesystem")
local loaded_state = require("loaded_state")

---@class git
local git = {}

---Execute a command in the command line and read its output
---@param cmd string the command to execute
---@param path string? the path to load the command in
---@return string | false # the command's output, or false if failure
---@return string? # the error message in case of failure, else nil
local function executeAndRead(cmd, path)
  if path then
    cmd = "cd " .. path .. " && " .. cmd
  end

  local handle = io.popen(cmd .. " 2>&1")
  if not handle then
    return false, "Could not execute command."
  end

  local result = handle:read("a"):match("(.-)%s*$")
  handle:close()
  return result
end

---Execute a command in the command line
---@param cmd string the command to execute
---@param path string? the path to load the command in
---@return true? # success state
local function executeCmd(cmd, path)
  if path then
    cmd = "cd " .. path .. " && " .. cmd
  end

  local success, _, __ = os.execute(cmd)
  return success
end

---Get the current loaded directory
---@return string? # the loaded directory or nil
local function loadedDir()
  if loaded_state.filename then
    return filesystem.dirname(loaded_state.filename)
  end

  return nil
end

---Determine if the state is within a repository
---@param path string? the path to check, or nil to use the loaded state
---@return boolean # true if within repository, false otherwise, including if failure
---@return string? # the error message in case of failure, nil otherwise
function git.isInRepo(path)
  local result, error = executeAndRead("git rev-parse --is-inside-work-tree", path or loadedDir())
  if not result then
    return false, error
  end

  return result == "true"
end

---Return the current repository's root directory
---@param path string? the path to check, or nil to use the loaded state
---@return string | false # the repository's root, or false if failure
---@return string? # the error message if failure, nil otherwise
function git.getRepoRoot(path)
  local result, error = executeAndRead("git rev-parse --show-toplevel", path or loadedDir())
  if not result then
    return false, error
  end

  return filesystem.joinpath(result)
end

return git