(local {: autoload : define} (require :conjure.nfnl.module))
(local a (autoload :conjure.nfnl.core))
(local log (autoload :conjure.log))
(local ts (autoload :conjure.tree-sitter))

(local M (define :conjure.lexical-search))

(fn nodes_eqv [l r]
  (let [(_ _ lsb) (l:start)
        (_ _ rsb) (r:start)
        (_ _ leb) (l:end_)
        (_ _ reb) (r:end_)]
    (and (= lsb rsb) (= leb reb))))

(fn get-captures-for-node [node opts results]
  (let [acc    (or results [])
        buffer (. opts :buffer)
        query  (. opts :query)
        labels (. opts :labels)
        captures (query:iter_captures node 0)]
    
    (icollect [id n captures]
      (let [value (vim.treesitter.get_node_text n buffer)
            captured-label (. query.captures id)]
        (when (and 
                (a.contains? labels captured-label) 
                (not (a.contains? acc value)))
          (table.insert acc value))))
    acc))

(fn get-captures-for-top-of-node [node opts results]
  (let [acc (or results [])
        node-results  []
        child-results []]
    (get-captures-for-node node opts node-results)

    (each [child (node:iter_children)]
      (when (not (nodes_eqv node child))
        (let [labels (. opts :labels)]
          (tset opts :labels (a.filter (fn [l] (not= l :global.define)) labels))
          (get-captures-for-node child opts child-results))))

    (each [_ v (ipairs node-results)]
      (when (and
              (not (a.contains? child-results v))
              (not (a.contains? acc v)))
        (table.insert acc v)))
    acc))

(fn query-through-priors-to-root [node opts results]
  (let [acc (or results [])
        parent (node:parent)]

    (when (not= parent nil)
      (var next-node node)
      (var labels [:global.define :local.define :local.bind])

      (while (not= next-node nil)
        (tset opts :labels labels) 
        (get-captures-for-top-of-node next-node opts acc)
        (set next-node (next-node:prev_sibling))
        (set labels [:global.define :local.define]))
      (query-through-priors-to-root parent opts acc))
    acc))

(fn get-captures-for-root-node [node opts]
  (tset opts :labels [:global.define :local.define])
  (get-captures-for-node node opts))

(fn M.get-query-captures [lang query]
  (let [opts {:buffer (vim.api.nvim_get_current_buf)
              :query  (vim.treesitter.query.parse lang query) }
        node (ts.get-node-at-cursor) ]
    (if (= (node:parent) nil)
      (get-captures-for-root-node node opts) 
      (query-through-priors-to-root node opts))))

M
