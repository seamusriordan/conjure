(fn wrap-require-fn-call [mod f]
  "We deliberately don't pass args through here because functions can behave
  very differently if they blindly accept args. If you need the args you should
  do your own function wrapping and not use this shorthand."
  (fn []
    ((. (require mod) f))))

(fn replace-termcodes [s]
  (vim.api.nvim_replace_termcodes s true false true))

(fn concat-nodup [a b]
  (let [seen {}
        result []]
    (each [_ v (ipairs a)]
      (when (not (. seen v) )
        (tset seen (tostring v) true)
        (table.insert result v)))
    (each [_ v (ipairs b)]
      (when (not (. seen v) )
        (tset seen (tostring v) true)
        (table.insert result v)))
    result))

{: wrap-require-fn-call
 : replace-termcodes
 : concat-nodup }
