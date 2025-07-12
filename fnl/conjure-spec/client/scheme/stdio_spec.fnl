(local {: describe : it } (require :plenary.busted))
(local assert (require :luassert.assert))
(local stdio (require :conjure.client.scheme.stdio))
(local config (require :conjure.config))
(local mock-tsc (require :conjure-spec.mock-tree-sitter-completions))
(local mock-log (require :conjure-spec.mock-log))

(tset package.loaded "conjure.tree-sitter-completions" mock-tsc)
(tset package.loaded "conjure.log" mock-log)

(describe "conjure.client.scheme.stdio"
  (fn []
    (describe "completions"
      (fn []
        (it "returns delay for prefix dela when no treesitter completions"
          (fn []
            (let [completion-results []
                  completion-callback 
                  (fn [res] (table.insert completion-results res))] 
              (mock-tsc.set-mock-completions [])

              (stdio.completions 
                {:prefix "dela"
                 :cb completion-callback})

              (assert.same ["delay"] (. completion-results 1)))))

        (it "returns delta for prefix delt when treesitter completion delta and other"
          (fn []
            (let [completion-results []
                  completion-callback 
                  (fn [res] (table.insert completion-results res))] 
              (mock-tsc.set-mock-completions ["delta" "other"])

              (stdio.completions 
                {:prefix "delt"
                 :cb completion-callback})

              (assert.same ["delta"] (. completion-results 1)))))

        (it "returns delay-more and delay for prefix dela when treesitter completion delay-more"
          (fn []
            (let [completion-results []
                  completion-callback 
                  (fn [res] (table.insert completion-results res))] 
              (mock-tsc.set-mock-completions ["delay-more"])

              (stdio.completions 
                {:prefix "dela"
                 :cb completion-callback})

              (assert.same ["delay-more" "delay"] (. completion-results 1)))))))

    (describe "config"
      (fn []
        (it "returns empty list for completions when completions disabled"
          (fn []
            (config.merge {:client {:scheme {:stdio
                            {:enable_completions false}}}}
                          {:overwrite? true})

            (let [completion-results []
                  completion-callback 
                  (fn [res] (table.insert completion-results res))] 
              (mock-tsc.set-mock-completions ["delay"])

              (stdio.completions 
                {:prefix "dela"
                 :cb completion-callback})

              (assert.same [] (. completion-results 1)))))

        (it "returns delay delay-more for completions when completions enabled and tree sitter completion delay-more"
            (fn []
              (config.merge {:client {:scheme {:stdio
                               {:enable_completions true}}}}
                            {:overwrite? true})
              (let [completion-results []
                    completion-callback 
                    (fn [res] (table.insert completion-results res))] 
                (mock-tsc.set-mock-completions ["delay-more"])

                (stdio.completions 
                  {:prefix "dela"
                   :cb completion-callback})

                (assert.same ["delay-more" "delay"] (. completion-results 1)))))))))
