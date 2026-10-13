---@meta git

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

  local result = handle:read("a")
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

function git.isInRepo(path)
  local result, error = executeAndRead("git rev-parse --is-inside-work-tree", path)
  if not result then
    return false, error
  end

  return result == "true"
end

function git.getRepoRoot(path)
  return executeAndRead("git rev-parse --show-toplevel", path)
end

return git