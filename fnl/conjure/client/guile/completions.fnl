(local {: autoload : define} (require :conjure.nfnl.module))
(local a (autoload :conjure.nfnl.core))
(local ts (autoload :conjure.tree-sitter))
(local log (autoload :conjure.log))

(local nvts (let [(ok? x) (pcall #(require :nvim-treesitter.query))]
              (when ok?
                x)))

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

(fn get-locals-for-node [node opts results]
  (let [buffer (. opts :buffer)
        query (. opts :query)
        label (. opts :label)
        captures (query:iter_captures node 0)]
    (icollect [id n captures]
      (let [value (vim.treesitter.get_node_text n buffer)
            captured-label (. query.captures id)]
        (when (= captured-label label)
          (table.insert results value))))))

(fn get-locals-for-top-of-node [node opts results]
  (let [node-results []
        child-results []]
    (get-locals-for-node node opts node-results)

    (each [child (node:iter_children)]
      (get-locals-for-node child opts child-results))

    (each [_ v (ipairs node-results)]
      (when (not (a.contains? child-results v))
        (table.insert results v))))
  results)

(fn query-through-priors-to-root [node opts results]
  (let [acc (or results [])
        parent (node:parent)]
    (when (not= parent nil)
      (var next-node node)
      (while (not= next-node nil)
        (get-locals-for-top-of-node next-node opts acc)
        (set next-node (next-node:prev_sibling)))
      (query-through-priors-to-root parent opts acc))
    acc))

(fn M.get-lexical-variables []
  (let [opts {:buffer (vim.api.nvim_get_current_buf)
              :query (vim.treesitter.query.parse :scheme locals-query)
              :label :local }
        node (ts.get-node-at-cursor)
        results (query-through-priors-to-root node opts)]
    (log.dbg ["Found lexical symbols " (a.pr-str results)])
    results))

M
