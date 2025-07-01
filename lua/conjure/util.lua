-- [nfnl] fnl/conjure/util.fnl
local function wrap_require_fn_call(mod, f)
  local function _1_()
    return require(mod)[f]()
  end
  return _1_
end
local function replace_termcodes(s)
  return vim.api.nvim_replace_termcodes(s, true, false, true)
end
local function concat_nodup(a, b)
  local seen = {}
  local result = {}
  for _, v in ipairs(a) do
    if not seen[v] then
      seen[tostring(v)] = true
      table.insert(result, v)
    else
    end
  end
  for _, v in ipairs(b) do
    if not seen[v] then
      seen[tostring(v)] = true
      table.insert(result, v)
    else
    end
  end
  return result
end
return {["wrap-require-fn-call"] = wrap_require_fn_call, ["replace-termcodes"] = replace_termcodes, ["concat-nodup"] = concat_nodup}
