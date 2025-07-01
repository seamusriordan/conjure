(local {: autoload : define} (require :conjure.nfnl.module))
(local a (autoload :conjure.nfnl.core))
(local ts (autoload :conjure.tree-sitter))
(local dict (autoload :conjure.client.scheme.dict))
(local log (autoload :conjure.log))
(local config (autoload :conjure.config))
(local dict (autoload :conjure.client.scheme.dict))

(local M (define :conjure.client.scheme.completions))

(local locals-query "
  (list 
    . (symbol) @_d
    . (list
        [
         (symbol) @local
         (list (symbol) @local) 
         ]) (#any-of? @_d \"define\" \"define*\" \"lambda\" \"named-lambda\" \"syntax-rules\" \"define-structure\" \"receive\" \"define-record-type\"))

  (list 
    . (symbol) @_d
    . (symbol) @local
    (#any-of? @_d \"define\" \"define-syntax\"))

  (list 
    . (symbol) @_d
    . (list 
        (list . (symbol) @local))
    (#any-of? @_d \"let\" \"let*\" \"let-syntax\" \"let*-syntax\" \"let-values\" \"let*-values\" \"letrec\" \"let-rec*\" \"letrec-syntax\" \"fluid-let\" \"and-let*\"))

  ;; named let
  (list 
    . (symbol) @_d
    . (symbol) @local
    . (list 
        (list . (symbol) @local))
    (#any-of? @_d \"let\" \"let*\" \"letrec\" \"let-rec*\"))

  (list
    . (symbol) @_do
    . (list
        (list . (symbol) @local)
        )
    (#any-of? @_do \"do\"))
  ")

(fn get-dict-key-from-stdio-command [command]
  (if 
    (= command nil) :default
    (string.match command "mit") :mit
    (string.match command "petite") :chez
    (string.match command "csi") :chicken
    :default))

(fn M.get-completions []
  (let [stdio-command (config.get-in [:client :scheme :stdio :command])
        dict-key (get-dict-key-from-stdio-command stdio-command)
        built-in-symbols (. dict dict-key) ]
    (a.concat
    (ts.get-query-captures
      :scheme
      locals-query
      [:local])
    built-in-symbols)))

M
