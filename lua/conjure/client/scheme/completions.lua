-- [nfnl] fnl/conjure/client/scheme/completions.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local a = autoload("conjure.aniseed.core")
local dict = autoload("conjure.client.scheme.dict")
local log = autoload("conjure.log")
local config = autoload("conjure.config")
local dict0 = autoload("conjure.client.scheme.dict")
local util = autoload("conjure.util")
local tsq = autoload("conjure.tree-sitter-query")
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
M["get-completions"] = function()
  local stdio_command = config["get-in"]({"client", "scheme", "stdio", "command"})
  local dict_key = get_dict_key_from_stdio_command(stdio_command)
  local built_in_symbols = dict0["get-dict"](dict_key)
  return util["concat-nodup"](tsq["get-scoped-symbols"]("scheme"), built_in_symbols)
end
return M
