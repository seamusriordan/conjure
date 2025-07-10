-- [nfnl] fnl/conjure/client/common-lisp/completions.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local tsq = autoload("conjure.tree-sitter-query")
local M = define("conjure.client.common-lisp.completions")
M["get-lexical-completions"] = function()
  return tsq["get-scoped-symbols"]("common-lisp", "commonlisp")
end
return M
