-- [nfnl] fnl/conjure/client/scheme/completions.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local ls = autoload("conjure.lexical-search")
local dict = autoload("conjure.client.scheme.dict")
local log = autoload("conjure.log")
local config = autoload("conjure.config")
local dict0 = autoload("conjure.client.scheme.dict")
local util = autoload("conjure.util")
local M = define("conjure.client.scheme.completions")
M["locals-query"] = "\n  (list \n    . (symbol) @_d\n    . (list\n         . (symbol) @local.define\n         ((symbol) @local.bind)*\n         (list (symbol)* @local.bind)*\n      )\n    (#any-of? @_d \"define\" \"define*\"))\n    @local.scope\n\n  (list\n    . (symbol) @_l\n    . (list\n         ((symbol) @local.bind)*\n         (list (symbol)* @local.bind)*\n      ) \n    (#any-of? @_l \"lambda\"))\n    @local.scope\n\n  (list\n    . (symbol) @_d\n    . (symbol) @local.define\n    (#any-of? @_d \"define\" \"define-syntax\"))\n    @local.scope\n\n  (list\n    . (symbol) @_l\n    . (list\n        (list . (symbol) @local.bind))\n    (#any-of? @_l \"let\" \"let*\" \"let-syntax\" \"letrec\" \"letrec-syntax\"))\n    @local.scope\n\n  (list\n    . (symbol) @_sr\n    . (list)\n    . (list ; square bracket\n        (list\n          . (_) (symbol)* @local.bind\n        )\n      )*\n    (#eq? @_sr \"syntax-rules\"))\n    @local.scope\n\n  (list\n    . (symbol) @_l\n    . (list\n        (list . (list (symbol) @local.bind)))\n    (#any-of? @_l \"let-values\" \"let*-values\"))\n    @local.scope\n\n  ;; named let\n  (list\n    . (symbol) @_l\n    . (symbol) @local.bind\n    . (list\n        (list . (symbol) @local.bind))\n    (#any-of? @_l \"let\" \"let*\" \"letrec\"))\n    @local.scope\n\n  (list\n    . (symbol) @_do\n    . (list\n        (list . (symbol) @local.bind)\n      )\n    (#any-of? @_do \"do\"))\n    @local.scope\n  "
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
  local built_in_symbols = dict0[dict_key]
  return util["concat-nodup"](ls["get-lexical-captures"]("scheme", M["locals-query"]), built_in_symbols)
end
return M
