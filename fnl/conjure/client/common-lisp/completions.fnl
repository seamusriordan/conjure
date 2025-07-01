(local {: autoload : define} (require :conjure.nfnl.module))
(local a (autoload :conjure.nfnl.core))
(local log (autoload :conjure.log))
(local ts (autoload :conjure.tree-sitter))

(local M (define :conjure.client.common-lisp.completions))

(fn M.get-lexical-variables []
  (ts.get-file-query-captures
    :commonlisp
    :locals
    ; [:local.definition.parameter :local.definition.type :local.reference
    ;  :local.definition.var :local.definition.function :local.definition.import]
    [:local.scope]
    ))

M
