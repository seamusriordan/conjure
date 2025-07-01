-- [nfnl] fnl/conjure/client/common-lisp/completions.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local a = autoload("conjure.nfnl.core")
local log = autoload("conjure.log")
local ts = autoload("conjure.tree-sitter")
local M = define("conjure.client.common-lisp.completions")
M["get-lexical-variables"] = function()
  return ts["get-file-query-captures"]("commonlisp", "locals", {"local.scope"})
end
return M
