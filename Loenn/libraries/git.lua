---@meta git

---@class git
local git = {}

local function executeAndRead(cmd)
  local handle = io.popen(cmd)
  if not handle then
    return false, "Could not execute command."
  end

  local result = handle:read("a")
  handle:close()
  return result
end

local function executeCmd(cmd)
  local success, _, __ = os.execute(cmd)
  return success
end

function git.isInRepo()
  local result, error = executeAndRead("git rev-parse --is-inside-work-tree")
  if not result then
    return false, error
  end

  return result == "true"
end

function git.getRepoRoot()
  return executeAndRead("git rev-parse --show-toplevel")
end

return git