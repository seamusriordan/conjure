-- [nfnl] fnl/conjure/client/scheme/completions.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local a = autoload("conjure.nfnl.core")
local ts = autoload("conjure.tree-sitter")
local dict = autoload("conjure.client.scheme.dict")
local log = autoload("conjure.log")
local config = autoload("conjure.config")
local dict0 = autoload("conjure.client.scheme.dict")
local M = define("conjure.client.scheme.completions")
local locals_query = "\n  (list \n    . (symbol) @_d\n    . (list\n        [\n         (symbol) @local\n         (list (symbol) @local) \n         ]) (#any-of? @_d \"define\" \"define*\" \"lambda\" \"named-lambda\" \"syntax-rules\" \"define-structure\" \"receive\" \"define-record-type\"))\n\n  (list \n    . (symbol) @_d\n    . (symbol) @local\n    (#any-of? @_d \"define\" \"define-syntax\"))\n\n  (list \n    . (symbol) @_d\n    . (list \n        (list . (symbol) @local))\n    (#any-of? @_d \"let\" \"let*\" \"let-syntax\" \"let*-syntax\" \"let-values\" \"let*-values\" \"letrec\" \"let-rec*\" \"letrec-syntax\" \"fluid-let\" \"and-let*\"))\n\n  ;; named let\n  (list \n    . (symbol) @_d\n    . (symbol) @local\n    . (list \n        (list . (symbol) @local))\n    (#any-of? @_d \"let\" \"let*\" \"letrec\" \"let-rec*\"))\n\n  (list\n    . (symbol) @_do\n    . (list\n        (list . (symbol) @local)\n        )\n    (#any-of? @_do \"do\"))\n  "
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
  return a.concat(ts["get-query-captures"]("scheme", locals_query, {"local"}), built_in_symbols)
end
return M
