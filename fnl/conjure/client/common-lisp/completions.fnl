(local {: autoload : define} (require :conjure.nfnl.module))
(local ls (autoload :conjure.lexical-search))
(local tsq (autoload :conjure.tree-sitter-queries))

(local M (define :conjure.client.common-lisp.completions))

(fn M.get-lexical-completions []
  (ls.get-lexical-captures
    :commonlisp ; This naming convention is required for treesitter
    (tsq.get-completion-query :common-lisp)))

M
