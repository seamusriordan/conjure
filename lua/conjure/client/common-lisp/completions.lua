-- [nfnl] fnl/conjure/client/common-lisp/completions.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local ls = autoload("conjure.lexical-search")
local tsq = autoload("conjure.tree-sitter-queries")
local M = define("conjure.client.common-lisp.completions")
M["get-lexical-completions"] = function()
  return ls["get-lexical-captures"]("commonlisp", tsq["get-completion-query"]("common-lisp"))
end
return M
