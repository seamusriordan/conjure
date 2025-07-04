-- [nfnl] fnl/conjure/tree-sitter-queries.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local a = autoload("conjure.nfnl.core")
local log = autoload("conjure.log")
local M = define("conjure.tree-sitter-queries")
local completion_query_path_template = "queries/%s/cmpl.scm"
local cache = {}
local function read_and_cache_file_contents(path)
  log.dbg({(path .. " query not cached - reading")})
  local file = io.open(path, "r")
  local content
  if (nil == file) then
    content = ""
  else
    content = file:read("*all")
  end
  if (nil ~= file) then
    file:close()
  else
  end
  cache[path] = content
  return content
end
local function get_cached_file_contents(path)
  if cache[path] then
    return cache[path]
  else
    return read_and_cache_file_contents(path)
  end
end
M["get-completion-query"] = function(lang)
  local query_path = string.format(completion_query_path_template, lang)
  local paths = vim.api.nvim_get_runtime_file(query_path, false)
  if (#paths > 0) then
    return get_cached_file_contents(paths[1])
  else
    return ""
  end
end
return M
