-- [nfnl] fnl/conjure/lexical-search.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local a = autoload("conjure.nfnl.core")
local log = autoload("conjure.log")
local ts = autoload("conjure.tree-sitter")
local M = define("conjure.lexical-search")
local function nodes_eqv(l, r)
  local _, _0, lsb = l:start()
  local _1, _2, rsb = r:start()
  local _3, _4, leb = l:end_()
  local _5, _6, reb = r:end_()
  return ((lsb == rsb) and (leb == reb))
end
local function get_captures_for_node(node, opts, results)
  local acc = (results or {})
  local buffer = opts.buffer
  local query = opts.query
  local labels = opts.labels
  local captures = query:iter_captures(node, 0)
  do
    local tbl_21_ = {}
    local i_22_ = 0
    for id, n in captures do
      local val_23_
      do
        local value = vim.treesitter.get_node_text(n, buffer)
        local captured_label = query.captures[id]
        if (a["contains?"](labels, captured_label) and not a["contains?"](acc, value)) then
          val_23_ = table.insert(acc, value)
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
  end
  return acc
end
local function get_captures_for_top_of_node(node, opts, results)
  local acc = (results or {})
  local node_results = {}
  local child_results = {}
  get_captures_for_node(node, opts, node_results)
  for child in node:iter_children() do
    if not nodes_eqv(node, child) then
      local labels = opts.labels
      local function _4_(l)
        return (l ~= "global.define")
      end
      opts["labels"] = a.filter(_4_, labels)
      get_captures_for_node(child, opts, child_results)
    else
    end
  end
  for _, v in ipairs(node_results) do
    if (not a["contains?"](child_results, v) and not a["contains?"](acc, v)) then
      table.insert(acc, v)
    else
    end
  end
  return acc
end
local function query_through_priors_to_root(node, opts, results)
  local acc = (results or {})
  local parent = node:parent()
  if (parent ~= nil) then
    local next_node = node
    local labels = {"global.define", "local.define", "local.bind"}
    while (next_node ~= nil) do
      opts["labels"] = labels
      get_captures_for_top_of_node(next_node, opts, acc)
      next_node = next_node:prev_sibling()
      labels = {"global.define", "local.define"}
    end
    query_through_priors_to_root(parent, opts, acc)
  else
  end
  return acc
end
local function get_captures_for_root_node(node, opts)
  opts["labels"] = {"global.define", "local.define"}
  return get_captures_for_node(node, opts)
end
M["get-query-captures"] = function(lang, query)
  local opts = {buffer = vim.api.nvim_get_current_buf(), query = vim.treesitter.query.parse(lang, query)}
  local node = ts["get-node-at-cursor"]()
  if (node:parent() == nil) then
    return get_captures_for_root_node(node, opts)
  else
    return query_through_priors_to_root(node, opts)
  end
end
return M
