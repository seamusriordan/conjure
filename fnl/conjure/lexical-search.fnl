(local {: autoload : define} (require :conjure.nfnl.module))
(local a (autoload :conjure.nfnl.core))
(local ts (autoload :conjure.tree-sitter))
(local util (autoload :conjure.util))

(local M (define :conjure.lexical-search))

(fn nodes_eqv [l r]
  (let [(_ _ lsb) (l:start)
        (_ _ rsb) (r:start)
        (_ _ leb) (l:end_)
        (_ _ reb) (r:end_)]
    (and (= lsb rsb) (= leb reb))))

(fn get-captures-for-node [node opts]
  (let [results []
        buffer (. opts :buffer)
        query  (. opts :query)
        labels (. opts :labels)
        captures (query:iter_captures node 0)]

    (icollect [id n captures]
      (let [value (vim.treesitter.get_node_text n buffer)
            captured-label (. query.captures id)]
        (when (a.contains? labels captured-label)
          (table.insert results value))))
    results))

(fn get-captures-for-top-of-node [node opts]
  (let [results       []
        node-results  (get-captures-for-node node opts)
        child-results []]

    (each [child (node:iter_children)]
      (when (not (nodes_eqv node child))
        (let [labels (. opts :labels)]
          (tset opts :labels (a.filter (fn [l] (not= l :global.define)) labels))
          (util.add-to child-results (get-captures-for-node child opts)))))

    (each [_ v (ipairs node-results)]
      (when (not (a.contains? child-results v))
        (table.insert results v)))
    results))

(fn query-through-priors-to-root [node opts]
  (let [results []
        parent (node:parent)]

    (when (not= parent nil)
      (var next-node node)
      (var labels [:global.define :local.define :local.bind])

      (while (not= next-node nil)
        (tset opts :labels labels) 
        (util.add-to results (get-captures-for-top-of-node next-node opts))
        (set next-node (next-node:prev_sibling))
        (set labels [:global.define :local.define]))
      (util.add-to results (query-through-priors-to-root parent opts)))
    results))

(fn get-captures-for-root-node [node opts]
  (tset opts :labels [:global.define :local.define])
  (get-captures-for-node node opts))

(fn M.get-lexical-captures-for-query [lang query]
  (let [opts {:buffer (vim.api.nvim_get_current_buf)
              :query  (vim.treesitter.query.parse lang query) }
        node (ts.get-node-at-cursor)
        result (if (= (node:parent) nil)
                 (get-captures-for-root-node node opts) 
                 (query-through-priors-to-root node opts))]
    (util.dedup result)))

M
