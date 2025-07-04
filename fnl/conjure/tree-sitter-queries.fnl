(local {: autoload : define} (require :conjure.nfnl.module))
(local a (autoload :conjure.nfnl.core))
(local log (autoload :conjure.log))

(local M (define :conjure.tree-sitter-queries))

(local completion-query-path-template "queries/%s/cmpl.scm")

(var cache {})

(fn read-and-cache-file-contents [path]
  (log.dbg [(.. path " query not cached - reading")])
  (let [file (io.open path "r")
        content (if (= nil file) "" (file:read "*all"))]
    (when (not= nil file)
      (file:close))
    (tset cache path content)
    content))

(fn get-cached-file-contents [path]
  (if (. cache path)
    (. cache path)
    (read-and-cache-file-contents path)))

(fn M.get-completion-query [lang]
  (let [query-path (string.format completion-query-path-template lang)
        paths (vim.api.nvim_get_runtime_file query-path false)]
    (if (> (length paths) 0)
      (get-cached-file-contents (. paths 1)) 
      "")))

M
