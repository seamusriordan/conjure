(local {: autoload : define} (require :conjure.nfnl.module))
(local a (autoload :conjure.nfnl.core))
(local ts (autoload :conjure.tree-sitter))
(local util (autoload :conjure.util))

(local M (define :conjure.lexical-search))

(fn contains-node [nodes n]
  (if 
    (= nil n)
    false
    (a.some #(n:equal $1) nodes)))

(fn contains-node-or-nil [nodes n]
  (if 
    (= nil n)
    true
    (contains-node nodes n)))

(fn get-scope-parent [node scopes] 
  (if (= nil node)
         nil
      (= nil (node:parent))
         nil
      (contains-node scopes (node:parent))
         (node:parent)
      (get-scope-parent (node:parent) scopes)))

(fn get-nth-scope-parent [n node scopes] 
  (if (= n 0)
    node
    (get-nth-scope-parent (- n 1) (get-scope-parent node scopes) scopes)))

(fn get-node-scopes [node scopes matched-scopes]
  (let [acc (or matched-scopes [])
        next-scope (get-scope-parent node scopes)]

    (when (contains-node scopes node)
      (table.insert acc node))

    (if 
      (= nil next-scope)
      acc
      (get-node-scopes next-scope scopes acc))))

(fn extract-scopes [query captures]
  (let [results []] 
    (each [id n captures]
      (let [captured-label (. query.captures id)]
        (if (= :local.scope captured-label)
          (table.insert results n))))
    results))

(fn get-lexical-captures-at-cursor [query]
  (let [buffer         (vim.api.nvim_get_current_buf)
        cursor-node    (ts.get-node-at-cursor) 
        (row _)        (unpack (vim.api.nvim_win_get_cursor 0))
        tree           (cursor-node:tree)
        scope-captures (query:iter_captures (tree:root) buffer 0 row)
        scopes         (extract-scopes query scope-captures buffer)
        cursor-scopes  (get-node-scopes cursor-node scopes) 
        captures       (query:iter_captures (tree:root) buffer 0 row) 
        results        [] ]

    (each [id n captures]
      (let [ captured-label (. query.captures id) ]
          (if 
            (= :global.define captured-label)
            (table.insert results (vim.treesitter.get_node_text n buffer))

            (and (= :local.bind captured-label) 
                 (contains-node-or-nil cursor-scopes (get-nth-scope-parent 1 n scopes)))
            (table.insert results (vim.treesitter.get_node_text n buffer))

            (and (= :local.define captured-label) 
                 (contains-node-or-nil cursor-scopes (get-nth-scope-parent 2 n scopes)))
            (table.insert results (vim.treesitter.get_node_text n buffer)))))

    (util.dedup results)))

(fn M.get-lexical-captures [lang raw-query]
  (let [ query  (vim.treesitter.query.parse lang raw-query) ]
    (get-lexical-captures-at-cursor query)))

M
