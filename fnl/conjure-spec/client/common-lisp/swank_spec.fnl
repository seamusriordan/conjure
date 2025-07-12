(local {: describe : it : spy : before_each} (require :plenary.busted))
(local a (require :conjure.nfnl.core))
(local assert (require :luassert.assert))
(local swank (require :conjure.client.common-lisp.swank))
(local config (require :conjure.config))
(require :conjure-spec.assertions)

(local mock-tsc (require :conjure-spec.mock-tree-sitter-completions))
(local mock-remote (require :conjure-spec.remote.mock-swank))

(tset package.loaded "conjure.remote.swank" mock-remote)
(tset package.loaded "conjure.tree-sitter-completions" mock-tsc)

(fn format-swank-return [output]
  (let [formatted-output (string.sub (a.pr-str output) 2 -2)]
    (string.format "(:return (:ok (\"\" \"(%s)\")) 0)" formatted-output)))

(describe "conjure.client.common-lisp.swank"
  (fn []
    (before_each 
      (fn []
        (mock-remote.clear-send-calls)))

    (describe "completions"
      (fn []
        (it "returns empty list when not connected and no treesitter completions"
          (fn []
            (let [completion-cb-calls []
                  completion-cb 
                  (fn [res]
                    (table.insert completion-cb-calls res))]
              (mock-tsc.set-mock-completions [])

              (swank.completions 
                {:prefix ""
                 :cb completion-cb})

             (assert.same [] (. completion-cb-calls 1)))))

        (it "returns defun when connected and swank completions returns defun and no treesitter completions"
          (fn []
            (let [completion-cb-calls []
                  completion-cb 
                  (fn [res]
                    (table.insert completion-cb-calls res))]
              (mock-tsc.set-mock-completions [])

              (swank.connect {})
              (swank.completions 
                {:prefix "def"
                 :cb completion-cb})
              ((a.get-in mock-remote.send-calls [2 :cb]) 
               (format-swank-return "(\"defun\") \"def\""))
              (swank.disconnect)

              (assert.has-substring 
                "swank:simple%-completions \\\"def\\\"" 
                (a.get-in mock-remote.send-calls [2 :msg]))

              (assert.same ["defun"] (. completion-cb-calls 1)))))

        (it "returns defunct defun when connected and swank completions returns defun and treesitter completions returns defunct"
          (fn []
            (let [completion-cb-calls []
                  completion-cb 
                  (fn [res]
                    (table.insert completion-cb-calls res))]
              (mock-tsc.set-mock-completions ["defunct"])

              (swank.connect {})
              (swank.completions 
                {:prefix "def"
                 :cb completion-cb})
              ((a.get-in mock-remote.send-calls [2 :cb]) 
               (format-swank-return "(\"defun\") \"def\""))
              (swank.disconnect)

              (assert.same ["defunct" "defun"] (. completion-cb-calls 1)))))

        (it "returns defunct when not connected and treesitter completions returns defunct"
          (fn []
            (let [completion-cb-calls []
                  completion-cb 
                  (fn [res]
                    (table.insert completion-cb-calls res))]
              (mock-tsc.set-mock-completions ["defunct"])

              (swank.completions 
                {:prefix "def"
                 :cb completion-cb})

              (assert.same [] mock-remote.send-calls)
              (assert.same ["defunct"] (. completion-cb-calls 1)))))

        (it "returns symbol when connected and swank completions returns symbol and treesitter completions returns symbol"
          (fn []
            (let [completion-cb-calls []
                  completion-cb 
                  (fn [res]
                    (table.insert completion-cb-calls res))]
              (mock-tsc.set-mock-completions ["symbol"])

              (swank.connect {})
              (swank.completions 
                {:prefix "s"
                 :cb completion-cb})
              ((a.get-in mock-remote.send-calls [2 :cb]) 
               (format-swank-return "(\"symbol\") \"s\""))
              (swank.disconnect)

              (assert.same ["symbol"] (. completion-cb-calls 1)))))))

    (describe "config"
      (fn []
        (it "returns no completions when connected and completions disabled"
          (fn []
            (config.merge {:client {:common_lisp {:swank
                             {:enable_completions false}}}}
                          {:overwrite? true})
            (let [completion-cb-calls []
                  completion-cb 
                  (fn [res]
                    (table.insert completion-cb-calls res))]
              (mock-tsc.set-mock-completions ["something"])

              (swank.connect {})
              (swank.completions 
                {:prefix "s"
                 :cb completion-cb})
              (swank.disconnect)

              (assert.are.equal 1 (length mock-remote.send-calls))
              (assert.same [] (. completion-cb-calls 1)))))

        (it "returns completions dots dotimes when connected with tree sitter results dots and completions enabled"
          (fn []
            (config.merge {:client {:common_lisp {:swank
                             {:enable_completions true}}}}
                          {:overwrite? true})
            (let [completion-cb-calls []
                  completion-cb 
                  (fn [res]
                    (table.insert completion-cb-calls res))]
              (mock-tsc.set-mock-completions ["dots"])

              (swank.connect {})
              (swank.completions 
                {:prefix "dot"
                 :cb completion-cb})
              ((a.get-in mock-remote.send-calls [2 :cb]) 
               (format-swank-return "(\"dotimes\") \"dot\""))
              (swank.disconnect)

              (assert.same ["dots" "dotimes"] (. completion-cb-calls 1)))))))))



