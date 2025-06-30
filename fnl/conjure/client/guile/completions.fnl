(local {: autoload : define} (require :conjure.nfnl.module))
(local a (autoload :conjure.nfnl.core))
(local ts (autoload :conjure.tree-sitter))
(local log (autoload :conjure.log))

(local nvts
  (let [(ok? x) (pcall #(require :nvim-treesitter.query))]
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
  (symbol) @variable
  ")

(fn get-locals-for-node [node opts results]
(let [
      buffer (. opts :buffer)
      query (. opts :query)
      captures (query:iter_captures node 0)]

  (icollect [_ v captures]
    (do
      (table.insert results (vim.treesitter.get_node_text v buffer))
      (log.append [(.. "found " (a.pr-str (vim.treesitter.get_node_text v buffer)))])))))

(fn query-through-priors-to-root [node opts results]
  (let [acc (or results [])]
    (log.append [(a.pr-str acc)])
    (var next-node (node:prev_sibling))

    (while (~= next-node nil)
      (get-locals-for-node next-node opts acc)
      (set next-node (next-node:prev_sibling))
      (log.append ["next prior sibling " (a.pr-str next-node)]))

    (let [parent (node:parent)]
      (when (~= parent nil)
        (log.append ["parent " (a.pr-str parent)])
        (query-through-priors-to-root parent opts acc)))
    acc))

(fn M.get-lexical-variables
  []
  (let [opts { :buffer (vim.api.nvim_get_current_buf)
               :query (vim.treesitter.query.parse :scheme locals-query) }
        node (ts.get-node-at-cursor) 
        results (query-through-priors-to-root node opts)]
    
        (log.append ["FINAL " (a.pr-str results )])
        results
      ))

M
