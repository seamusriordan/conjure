(local {: autoload : define} (require :conjure.nfnl.module))
(local dict (autoload :conjure.client.scheme.dict))
(local config (autoload :conjure.config))
(local dict (autoload :conjure.client.scheme.dict))
(local util (autoload :conjure.util))
(local tsc (autoload :conjure.tree-sitter-completions))

(local M (define :conjure.client.scheme.completions))

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
        built-in-symbols (dict.get-dict dict-key) ]
    (util.concat-nodup
      (tsc.get-completions-at-cursor :scheme :scheme)
      built-in-symbols)))

M
