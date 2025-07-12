-- [nfnl] fnl/conjure/client/scheme/completions.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local a = autoload("conjure.nfnl.core")
local dict = autoload("conjure.client.scheme.dict")
local config = autoload("conjure.config")
local util = autoload("conjure.util")
local tsc = autoload("conjure.tree-sitter-completions")
local M = define("conjure.client.scheme.completions")
local function get_dict_key_from_stdio_command(command)
  if (command == nil) then
    return "default"
  elseif string.match(command, "mit") then
    return "mit"
  elseif string.match(command, "petite") then
    return "chez"
  elseif string.match(command, "csi") then
    return "chicken"
  else
    return "default"
  end
end
M["get-completions"] = function(prefix)
  local stdio_command = config["get-in"]({"client", "scheme", "stdio", "command"})
  local dict_key = get_dict_key_from_stdio_command(stdio_command)
  local dict0 = dict["get-dict"](dict_key)
  local prefix_pattern = ("^" .. string.gsub(prefix, "%%", "%"))
  local prefix_filter
  local function _3_(s)
    return string.match(s, prefix_pattern)
  end
  prefix_filter = _3_
  return a.filter(prefix_filter, util["concat-nodup"](tsc["get-completions-at-cursor"]("scheme", "scheme"), dict0))
end
return M
