-- [nfnl] fnl/conjure/client/guile/completions.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local a = autoload("conjure.nfnl.core")
local ts = autoload("conjure.tree-sitter")
local M = define("conjure.client.guile.completions")
M["guile-repl-completion-code"] = "(use-modules ((ice-9 readline) \n      #:select (apropos-completion-function)\n      #:prefix %conjure:))\n  (define* (%conjure:get-guile-completions prefix #:optional (continued #f))\n      (let ((suggestion (%conjure:apropos-completion-function prefix continued)))\n        (if (not suggestion)\n          '()\n          (cons suggestion (%conjure:get-guile-completions prefix #t)))))"
M["build-completion-request"] = function(prefix)
  return ("(%conjure:get-guile-completions " .. a["pr-str"](prefix) .. ")")
end
local function parse_guile_completion_result(rs)
  local tbl_21_ = {}
  local i_22_ = 0
  for token in string.gmatch(rs, "\"([^\"^%s]+)\"") do
    local val_23_ = token
    if (nil ~= val_23_) then
      i_22_ = (i_22_ + 1)
      tbl_21_[i_22_] = val_23_
    else
    end
  end
  return tbl_21_
end
M["format-results"] = function(rs)
  local cmpls = parse_guile_completion_result(rs)
  local last = table.remove(cmpls)
  table.insert(cmpls, 1, last)
  return cmpls
end
local locals_query = "\n  (list \n    . (symbol) @_d\n    . (list\n        [\n         (symbol) @local\n         (list (symbol) @local) \n         ])\n    (#any-of? @_d \"define\" \"define*\" \"lambda\" \"syntax-rules\"))\n\n  (list \n    . (symbol) @_d\n    . (symbol) @local\n    (#any-of? @_d \"define\" \"define-syntax\"))\n\n  (list \n    . (symbol) @_d\n    . (list \n        (list . (symbol) @local))\n    (#any-of? @_d \"let\" \"let*\" \"let-syntax\" \"let-values\" \"let*-values\" \"letrec\" \"letrec-syntax\"))\n\n  ;; named let\n  (list \n    . (symbol) @_d\n    . (symbol) @local\n    . (list \n        (list . (symbol) @local))\n    (#any-of? @_d \"let\" \"let*\" \"letrec\"))\n\n  (list\n    . (symbol) @_do\n    . (list\n        (list . (symbol) @local)\n        )\n    (#any-of? @_do \"do\"))\n  "
M["get-lexical-variables"] = function()
  return ts["get-query-captures"]("scheme", locals_query, "local")
end
return M
