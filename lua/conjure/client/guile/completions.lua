-- [nfnl] fnl/conjure/client/guile/completions.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local a = autoload("conjure.nfnl.core")
local ts = autoload("conjure.tree-sitter")
local log = autoload("conjure.log")
local nvts
do
  local ok_3f, x = nil, nil
  local function _2_()
    return require("nvim-treesitter.query")
  end
  ok_3f, x = pcall(_2_)
  if ok_3f then
    nvts = x
  else
    nvts = nil
  end
end
local M = define("conjure.client.guile.completions")
M["guile-repl-completion-code"] = "(use-modules ((ice-9 readline) \n      #:select (apropos-completion-function)\n      #:prefix %conjure:))\n  (define* (%conjure:get-guile-completions prefix #:optional (continued #f))\n      (let ((suggestion (%conjure:apropos-completion-function prefix continued)))\n        (if (not suggestion)\n          '()\n          (cons suggestion (%conjure:get-guile-completions prefix #t)))))"
M["build-completion-request"] = function(prefix)
  return ("(%conjure:get-guile-completions " .. a["pr-str"](prefix) .. ")")
end
local function parse_guile_completion_result(rs)
  local tbl_21_ = {}
  local i_22_ = 0
  for token in string.gmatch(rs, "\"([^\"^%s]+)\"") do
    local val_23_ = token
    if (nil ~= val_23_) then
      i_22_ = (i_22_ + 1)
      tbl_21_[i_22_] = val_23_
    else
    end
  end
  return tbl_21_
end
M["format-results"] = function(rs)
  local cmpls = parse_guile_completion_result(rs)
  local last = table.remove(cmpls)
  table.insert(cmpls, 1, last)
  return cmpls
end
local locals_query = "\n  (list \n    . (symbol) @_d\n    . (list\n        [\n         (symbol) @local\n         (list (symbol) @local) \n         ])\n    (#any-of? @_d \"define\" \"define*\" \"lambda\" \"syntax-rules\"))\n\n  (list \n    . (symbol) @_d\n    . (symbol) @local\n    (#any-of? @_d \"define\" \"define-syntax\"))\n\n  (list \n    . (symbol) @_d\n    . (list \n        (list . (symbol) @local))\n    (#any-of? @_d \"let\" \"let*\" \"let-syntax\" \"let-values\" \"let*-values\" \"letrec\" \"letrec-syntax\"))\n\n  ;; named let\n  (list \n    . (symbol) @_d\n    . (symbol) @local\n    . (list \n        (list . (symbol) @local))\n    (#any-of? @_d \"let\" \"let*\" \"letrec\"))\n\n  (list\n    . (symbol) @_do\n    . (list\n        (list . (symbol) @local)\n        )\n    (#any-of? @_do \"do\"))\n  "
local function get_locals_for_node(node, opts, results)
  local buffer = opts.buffer
  local query = opts.query
  local label = opts.label
  local captures = query:iter_captures(node, 0)
  local tbl_21_ = {}
  local i_22_ = 0
  for id, n in captures do
    local val_23_
    do
      local value = vim.treesitter.get_node_text(n, buffer)
      local captured_label = query.captures[id]
      if (captured_label == label) then
        val_23_ = table.insert(results, value)
      else
        val_23_ = nil
      end
    end
    if (nil ~= val_23_) then
      i_22_ = (i_22_ + 1)
      tbl_21_[i_22_] = val_23_
    else
    end
  end
  return tbl_21_
end
local function get_locals_for_top_of_node(node, opts, results)
  do
    local node_results = {}
    local child_results = {}
    get_locals_for_node(node, opts, node_results)
    for child in node:iter_children() do
      get_locals_for_node(child, opts, child_results)
    end
    for _, v in ipairs(node_results) do
      if not a["contains?"](child_results, v) then
        table.insert(results, v)
      else
      end
    end
  end
  return results
end
local function query_through_priors_to_root(node, opts, results)
  local acc = (results or {})
  local parent = node:parent()
  if (parent ~= nil) then
    local next_node = node
    while (next_node ~= nil) do
      get_locals_for_top_of_node(next_node, opts, acc)
      next_node = next_node:prev_sibling()
    end
    query_through_priors_to_root(parent, opts, acc)
  else
  end
  return acc
end
M["get-lexical-variables"] = function()
  local opts = {buffer = vim.api.nvim_get_current_buf(), query = vim.treesitter.query.parse("scheme", locals_query), label = "local"}
  local node = ts["get-node-at-cursor"]()
  local results = query_through_priors_to_root(node, opts)
  log.dbg({"Found lexical symbols ", a["pr-str"](results)})
  return results
end
return M
