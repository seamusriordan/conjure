-- [nfnl] fnl/conjure/lexical-search.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local a = autoload("conjure.nfnl.core")
local ts = autoload("conjure.tree-sitter")
local log = autoload("conjure.log")
local util = autoload("conjure.util")
local M = define("conjure.lexical-search")
local function contains_node(nodes, n)
  if (nil == n) then
    return false
  else
    local function _2_(_241)
      return n:equal(_241)
    end
    return a.some(_2_, nodes)
  end
end
local function contains_node_or_nil(nodes, n)
  if (nil == n) then
    return true
  else
    return contains_node(nodes, n)
  end
end
local function get_scope_parent(node, scopes)
  if (nil == node) then
    return nil
  elseif (nil == node:parent()) then
    return nil
  elseif contains_node(scopes, node:parent()) then
    return node:parent()
  else
    return get_scope_parent(node:parent(), scopes)
  end
end
local function get_nth_scope_parent(n, node, scopes)
  if (n == 0) then
    return node
  else
    return get_nth_scope_parent((n - 1), get_scope_parent(node, scopes), scopes)
  end
end
local function get_node_scopes(node, scopes, matched_scopes)
  local acc = (matched_scopes or {})
  local next_scope = get_scope_parent(node, scopes)
  if contains_node(scopes, node) then
    table.insert(acc, node)
  else
  end
  if (nil == next_scope) then
    return acc
  else
    return get_node_scopes(next_scope, scopes, acc)
  end
end
local function extract_scopes(query, captures)
  local results = {}
  for id, n in captures do
    local captured_label = query.captures[id]
    if ("local.scope" == captured_label) then
      table.insert(results, n)
    else
    end
  end
  return results
end
local function get_captures_by_scope_for_node(node, query, buffer)
  local results = {}
  local tree = node:tree()
  local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
  local scope_captures = query:iter_captures(tree:root(), buffer, 0, row)
  local scopes = extract_scopes(query, scope_captures, buffer)
  local cursor_scopes = get_node_scopes(node, scopes)
  local captures = query:iter_captures(tree:root(), buffer, 0, row)
  for id, n in captures do
    local _0, _1, capture_byte_pos = n:start()
    local captured_label = query.captures[id]
    if ("global.define" == captured_label) then
      table.insert(results, vim.treesitter.get_node_text(n, buffer))
    elseif (("local.bind" == captured_label) and contains_node_or_nil(cursor_scopes, get_nth_scope_parent(1, n, scopes))) then
      table.insert(results, vim.treesitter.get_node_text(n, buffer))
    elseif (("local.define" == captured_label) and contains_node_or_nil(cursor_scopes, get_nth_scope_parent(2, n, scopes))) then
      table.insert(results, vim.treesitter.get_node_text(n, buffer))
    else
    end
  end
  return results
end
M["get-lexical-captures-for-query"] = function(lang, query)
  local node = ts["get-node-at-cursor"]()
  local query0 = vim.treesitter.query.parse(lang, query)
  local buffer = vim.api.nvim_get_current_buf()
  return util.dedup(get_captures_by_scope_for_node(node, query0, buffer))
end
return M
