-- [nfnl] fnl/conjure/lexical-search.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local a = autoload("conjure.nfnl.core")
local ts = autoload("conjure.tree-sitter")
local M = define("conjure.lexical-search")
local function get_captures_for_node(node, opts, results)
  local buffer = opts.buffer
  local query = opts.query
  local labels = opts.labels
  local captures = query:iter_captures(node, 0)
  local tbl_21_ = {}
  local i_22_ = 0
  for id, n in captures do
    local val_23_
    do
      local value = vim.treesitter.get_node_text(n, buffer)
      local captured_label = query.captures[id]
      if (a["contains?"](labels, captured_label) and not a["contains?"](results, value)) then
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
local function get_captures_for_top_of_node(node, opts, results)
  do
    local node_results = {}
    local child_results = {}
    get_captures_for_node(node, opts, node_results)
    for child in node:iter_children() do
      get_captures_for_node(child, opts, child_results)
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
    local labels = {"local.define", "local.bind"}
    while (next_node ~= nil) do
      opts["labels"] = labels
      get_captures_for_top_of_node(next_node, opts, acc)
      next_node = next_node:prev_sibling()
      labels = {"local.define"}
    end
    query_through_priors_to_root(parent, opts, acc)
  else
  end
  return acc
end
M["get-query-captures"] = function(lang, query)
  local opts = {buffer = vim.api.nvim_get_current_buf(), query = vim.treesitter.query.parse(lang, query)}
  local node = ts["get-node-at-cursor"]()
  local results = query_through_priors_to_root(node, opts)
  return results
end
M["get-file-query-captures"] = function(lang, query_file)
  local opts = {buffer = vim.api.nvim_get_current_buf(), query = vim.treesitter.query.get(lang, query_file)}
  local node = ts["get-node-at-cursor"]()
  local results = query_through_priors_to_root(node, opts)
  return results
end
return M
