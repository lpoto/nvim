--=============================================================================
-------------------------------------------------------------------------------
--                                                                         ROOT
--=============================================================================
-- Get the project's root directory
--_____________________________________________________________________________

local path = require "util.path"

---Find the root directory of the current project.
---Searches for the first directory in the path that contains one
---provided patterns.
---@param root_dir_patterns table?: (default: {'.git', '.nvim.root'})
---@param max_depth number?:  max depth to check for root (default: 10)
return function(root_dir_patterns, max_depth)
  if type(root_dir_patterns) ~= "table" or next(root_dir_patterns) == nil then
    root_dir_patterns = { ".git", ".nvim.root", ".nvim" }
  end
  if type(max_depth) ~= "number" then
    max_depth = 20
  end
  if vim.g["root_dir_max_depth"] then
    max_depth = vim.g["root_dir_max_depth"]
  end
  local p = vim.fn.getcwd()
  for _ = 1, max_depth, 1 do
    if string.len(p) == 1 or path.join(p, "") == os.getenv "HOME" then
      break
    end
    for _, pattern in ipairs(root_dir_patterns) do
      if
        vim.fn.filereadable(path.join(p, pattern)) == 1
        or vim.fn.isdirectory(path.join(p, pattern)) == 1
      then
        return p
      end
    end
    p = vim.fs.dirname(p)
  end
  return vim.fn.getcwd()
end
