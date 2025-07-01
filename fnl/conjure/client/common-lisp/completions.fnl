(local {: autoload : define} (require :conjure.nfnl.module))
(local a (autoload :conjure.nfnl.core))
(local log (autoload :conjure.log))
(local ts (autoload :conjure.tree-sitter))

(local M (define :conjure.client.common-lisp.completions))

(fn M.get-lexical-variables []
  (ts.get-query-captures
    :commonlisp
    :locals
    ))

M
