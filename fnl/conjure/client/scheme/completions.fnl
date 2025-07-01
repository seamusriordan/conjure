(local {: autoload : define} (require :conjure.nfnl.module))
(local a (autoload :conjure.nfnl.core))
(local ls (autoload :conjure.lexical-search))
(local dict (autoload :conjure.client.scheme.dict))
(local log (autoload :conjure.log))
(local config (autoload :conjure.config))
(local dict (autoload :conjure.client.scheme.dict))

(local M (define :conjure.client.scheme.completions))

(tset M :locals-query "
  (list 
    . (symbol) @_d
    . (list
         . (symbol) @local.define
         ((symbol) @local.bind)*
         (list (symbol)* @local.bind)*
      )
    (#any-of? @_d \"define\" \"define*\" \"lambda\"))

  (list 
    . (symbol) @_d
    . (symbol) @local.define
    (#any-of? @_d \"define\" \"define-syntax\"))

  (list 
    . (symbol) @_l
    . (list 
        (list . (symbol) @local.bind))
    (#any-of? @_l \"let\" \"let*\" \"let-syntax\" \"letrec\" \"letrec-syntax\"))

  (list 
    . (symbol) @_sr
    . (list) 
    . (list ; square bracket
        (list 
          . (_) (symbol)* @local.bind
        ) 
      )*
    (#eq? @_sr \"syntax-rules\"))
  
  (list 
    . (symbol) @_l
    . (list 
        (list . (list (symbol) @local.bind)))
    (#any-of? @_l \"let-values\" \"let*-values\"))

  ;; named let
  (list 
    . (symbol) @_l
    . (symbol) @local.define
    . (list 
        (list . (symbol) @local.bind))
    (#any-of? @_l \"let\" \"let*\" \"letrec\"))

  (list
    . (symbol) @_do
    . (list
        (list . (symbol) @local.bind)
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
      (ls.get-query-captures
        :scheme
        M.locals-query)
      built-in-symbols)))

M
