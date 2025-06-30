(local {: autoload : define} (require :conjure.nfnl.module))
(local a (autoload :conjure.nfnl.core))
(local ts (autoload :conjure.tree-sitter))

(local M (define :conjure.client.guile.completions))

(set M.guile-repl-completion-code
 "(use-modules ((ice-9 readline) 
      #:select (apropos-completion-function)
      #:prefix %conjure:))
  (define* (%conjure:get-guile-completions prefix #:optional (continued #f))
      (let ((suggestion (%conjure:apropos-completion-function prefix continued)))
        (if (not suggestion)
          '()
          (cons suggestion (%conjure:get-guile-completions prefix #t)))))")

(fn M.build-completion-request [prefix]
  (.. "(%conjure:get-guile-completions " (a.pr-str prefix) ")"))

(fn parse-guile-completion-result [rs]
  (icollect [token (string.gmatch rs "\"([^\"^%s]+)\"")]
    token))

(fn M.format-results [rs]
  (let [cmpls (parse-guile-completion-result rs)
        last (table.remove cmpls)]
    (table.insert cmpls 1 last)
    cmpls))

(local locals-query "
  (list 
    . (symbol) @_d
    . (list
        [
         (symbol) @local
         (list (symbol) @local) 
         ])
    (#any-of? @_d \"define\" \"define*\" \"lambda\" \"syntax-rules\"))

  (list 
    . (symbol) @_d
    . (symbol) @local
    (#any-of? @_d \"define\" \"define-syntax\"))

  (list 
    . (symbol) @_d
    . (list 
        (list . (symbol) @local))
    (#any-of? @_d \"let\" \"let*\" \"let-syntax\" \"let-values\" \"let*-values\" \"letrec\" \"letrec-syntax\"))

  ;; named let
  (list 
    . (symbol) @_d
    . (symbol) @local
    . (list 
        (list . (symbol) @local))
    (#any-of? @_d \"let\" \"let*\" \"letrec\"))

  (list
    . (symbol) @_do
    . (list
        (list . (symbol) @local)
        )
    (#any-of? @_do \"do\"))
  ")


(fn M.get-lexical-variables []
  (ts.get-query-captures
    :scheme
    locals-query
    :local))

M
