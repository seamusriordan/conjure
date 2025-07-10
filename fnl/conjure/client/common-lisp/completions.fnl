(local {: autoload : define} (require :conjure.nfnl.module))
(local tsq (autoload :conjure.tree-sitter-query))

(local M (define :conjure.client.common-lisp.completions))

(fn M.get-lexical-completions []
  (tsq.get-scoped-symbols
    :common-lisp
    :commonlisp )); This naming convention is required for treesitter

M
