-- [nfnl] fnl/conjure/util.fnl
local _local_1_ = require("conjure.nfnl.module")
local define = _local_1_["define"]
local M = define("conjure.util")
M["wrap-require-fn-call"] = function(mod, f)
  local function _2_()
    return require(mod)[f]()
  end
  return _2_
end
M["replace-termcodes"] = function(s)
  return vim.api.nvim_replace_termcodes(s, true, false, true)
end
M["concat-nodup"] = function(l, r)
  local seen = {}
  local result = {}
  for _, v in ipairs(l) do
    if not seen[v] then
      seen[v] = true
      table.insert(result, v)
    else
    end
  end
  for _, v in ipairs(r) do
    if not seen[v] then
      seen[v] = true
      table.insert(result, v)
    else
    end
  end
  return result
end
M["add-to"] = function(base, addend)
  for _, v in ipairs(addend) do
    table.insert(base, v)
  end
  return nil
end
M.dedup = function(t)
  return M["concat-nodup"]({}, t)
end
return M
