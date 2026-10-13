---@meta git

local filesystem = require("utils.filesystem")
local loaded_state = require("loaded_state")

---@class git
local git = {}

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

local function executeCmd(cmd, path)
  if path then
    cmd = "cd " .. path .. " && " .. cmd
  end

  local success, _, __ = os.execute(cmd)
  return success
end

local function loadedDir()
  if loaded_state.filename then
    return filesystem.dirname(loaded_state.filename)
  end

  return nil
end

function git.isInRepo(path)
  local result, error = executeAndRead("git rev-parse --is-inside-work-tree", path or loadedDir())
  if not result then
    return false, error
  end

  return result == "true"
end

function git.getRepoRoot(path)
  local result, error = executeAndRead("git rev-parse --show-toplevel", path or loadedDir())
  if not result then
    return false, error
  end

  return filesystem.dirname(result)
end

return git