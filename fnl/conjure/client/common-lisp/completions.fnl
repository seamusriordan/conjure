(local {: autoload : define} (require :conjure.nfnl.module))
(local ls (autoload :conjure.lexical-search))

(local M (define :conjure.client.common-lisp.completions))

(local locals-query "
  ")

(fn M.get-lexical-completions []
   (ls.get-query-captures
         :common-lisp
         M.locals-query))

M
