(local {: autoload : define} (require :conjure.nfnl.module))
(local a (autoload :conjure.nfnl.core))
(local ts (autoload :conjure.tree-sitter))

(local M (define :conjure.lexical-search))

(fn get-captures-for-node [node opts results]
  (let [buffer (. opts :buffer)
        query  (. opts :query)
        labels (. opts :labels)
        captures (query:iter_captures node 0)]
    
    (icollect [id n captures]
      (let [value (vim.treesitter.get_node_text n buffer)
            captured-label (. query.captures id)]
        (when (and 
                (a.contains? labels captured-label) 
                (not ( a.contains? results value)))
          (table.insert results value))))))

(fn get-captures-for-top-of-node [node opts results]
  (let [node-results []
        child-results []]
    (get-captures-for-node node opts node-results)

    (each [child (node:iter_children)]
      (get-captures-for-node child opts child-results))

    (each [_ v (ipairs node-results)]
      (when (not (a.contains? child-results v))
        (table.insert results v))))
  results)

(fn query-through-priors-to-root [node opts results]
  (let [acc (or results [])
        parent (node:parent)]
    (when (not= parent nil)
      (var next-node node)
      (var labels [:local.define :local.bind])

      (while (not= next-node nil)
        (tset opts :labels labels) 
        (get-captures-for-top-of-node next-node opts acc)
        (set next-node (next-node:prev_sibling))
        (set labels [:local.define]))

      (query-through-priors-to-root parent opts acc))
    acc))

(fn M.get-query-captures [lang query]
  (let [opts {:buffer (vim.api.nvim_get_current_buf)
              :query  (vim.treesitter.query.parse lang query) }
        node (ts.get-node-at-cursor)
        results (query-through-priors-to-root node opts)]
    results))

(fn M.get-file-query-captures [lang query-file]
  (let [opts {:buffer (vim.api.nvim_get_current_buf)
              :query  (vim.treesitter.query.get lang query-file) }
        node (ts.get-node-at-cursor)
        results (query-through-priors-to-root node opts)]
   results))

M
