-- [nfnl] fnl/conjure/client/common-lisp/completions.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local ls = autoload("conjure.lexical-search")
local M = define("conjure.client.common-lisp.completions")
local locals_query = "\n  "
M["get-lexical-completions"] = function()
  return ls["get-query-captures"]("common-lisp", M["locals-query"])
end
return M
