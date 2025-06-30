-- [nfnl] fnl/conjure/tree-sitter.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local a = autoload("conjure.nfnl.core")
local client = autoload("conjure.client")
local config = autoload("conjure.config")
local text = autoload("conjure.text")
local log = autoload("conjure.log")
local ts
do
  local ok_3f, x = nil, nil
  local function _2_()
    return require("nvim-treesitter.ts_utils")
  end
  ok_3f, x = pcall(_2_)
  if ok_3f then
    ts = x
  else
    ts = nil
  end
end
local function enabled_3f()
  local and_4_ = ("table" == type(ts)) and config["get-in"]({"extract", "tree_sitter", "enabled"})
  if and_4_ then
    local ok_3f, parser = pcall(vim.treesitter.get_parser)
    and_4_ = (ok_3f and parser)
  end
  if and_4_ then
    return true
  else
    return false
  end
end
local function parse_21()
  local ok_3f, parser = pcall(vim.treesitter.get_parser)
  if ok_3f then
    return parser:parse()
  else
    return nil
  end
end
local function node__3estr(node)
  if node then
    if vim.treesitter.get_node_text then
      return vim.treesitter.get_node_text(node, vim.api.nvim_get_current_buf())
    else
      return vim.treesitter.query.get_node_text(node, vim.api.nvim_get_current_buf())
    end
  else
    return nil
  end
end
local function lisp_comment_node_3f(node)
  return text["starts-with"](node__3estr(node), "(comment")
end
local function parent(node)
  if node then
    return node:parent()
  else
    return nil
  end
end
local function document_3f(node)
  return not parent(node)
end
local function range(node)
  if node then
    local sr, sc, er, ec = node:range()
    return {start = {a.inc(sr), sc}, ["end"] = {a.inc(er), a.dec(ec)}}
  else
    return nil
  end
end
local function node__3etable(node)
  if (a.get(node, "range") and a.get(node, "content")) then
    return node
  elseif node then
    return {range = range(node), content = node__3estr(node), node = node}
  else
    return nil
  end
end
local function get_root(node)
  parse_21()
  local node0 = (node or ts.get_node_at_cursor())
  local parent_node = parent(node0)
  if document_3f(node0) then
    return nil
  elseif document_3f(parent_node) then
    return node0
  elseif client["optional-call"]("comment-node?", parent_node) then
    return node0
  else
    return get_root(parent_node)
  end
end
local function leaf_3f(node)
  if node then
    return (0 == node:child_count())
  else
    return nil
  end
end
local function sym_3f(node)
  if node then
    return (string.find(node:type(), "sym") or client["optional-call"]("symbol-node?", node))
  else
    return nil
  end
end
local function get_node_at_cursor()
  return ts.get_node_at_cursor()
end
local function get_leaf(node)
  parse_21()
  local node0 = (node or ts.get_node_at_cursor())
  if (leaf_3f(node0) or sym_3f(node0)) then
    local node1 = node0
    while sym_3f(parent(node1)) do
      node1 = parent(node1)
    end
    return node1
  else
    return nil
  end
end
local function node_surrounded_by_form_pair_chars_3f(node, extra_pairs)
  local node_str = node__3estr(node)
  local first_and_last_chars = text["first-and-last-chars"](node_str)
  local function _18_(_17_)
    local start = _17_[1]
    local _end = _17_[2]
    return (first_and_last_chars == (start .. _end))
  end
  local or_19_ = a.some(_18_, config["get-in"]({"extract", "form_pairs"}))
  if not or_19_ then
    local function _21_(_20_)
      local start = _20_[1]
      local _end = _20_[2]
      return (vim.startswith(node_str, start) and vim.endswith(node_str, _end))
    end
    or_19_ = a.some(_21_, extra_pairs)
  end
  return (or_19_ or false)
end
local function node_prefixed_by_chars_3f(node, prefixes)
  local node_str = node__3estr(node)
  local function _22_(prefix)
    return vim.startswith(node_str, prefix)
  end
  return (a.some(_22_, prefixes) or false)
end
local function get_form(node)
  if not node then
    parse_21()
  else
  end
  local node0 = (node or ts.get_node_at_cursor())
  if document_3f(node0) then
    return nil
  elseif (leaf_3f(node0) or (false == client["optional-call"]("form-node?", node0))) then
    return get_form(parent(node0))
  else
    local _let_24_ = (client["optional-call"]("get-form-modifier", node0) or {})
    local modifier = _let_24_["modifier"]
    local res = _let_24_
    if (not modifier or ("none" == modifier)) then
      return node0
    elseif ("parent" == modifier) then
      return get_form(parent(node0))
    elseif ("node" == modifier) then
      return res.node
    elseif ("raw" == modifier) then
      return res["node-table"]
    else
      a.println("Warning: Conjure client returned an unknown get-form-modifier", res)
      return node0
    end
  end
end
local function add_language(lang)
  return (vim.treesitter.language.add or vim.treesitter.language.require_language or vim.treesitter.require_language)(lang)
end
local function get_captures_for_node(node, opts, results)
  log.append({"catchos"})
  log.append({a["pr-str"](opts.query)})
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
      val_23_ = table.insert(results, value)
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
    log.append({"node ", a["pr-str"](node_results)})
    log.append({"childnode ", a["pr-str"](child_results)})
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
  local parent0 = node:parent()
  if (parent0 ~= nil) then
    local next_node = node
    while (next_node ~= nil) do
      get_captures_for_top_of_node(next_node, opts, acc)
      next_node = next_node:prev_sibling()
    end
    query_through_priors_to_root(parent0, opts, acc)
  else
  end
  return acc
end
local function get_query_captures(lang, query, labels)
  local opts = {buffer = vim.api.nvim_get_current_buf(), query = vim.treesitter.query.parse(lang, query), labels = labels}
  local node = get_node_at_cursor()
  local results = query_through_priors_to_root(node, opts)
  return results
end
local function get_file_query_captures(lang, query_file, labels)
  log.append({"start"})
  local opts = {buffer = vim.api.nvim_get_current_buf(), query = vim.treesitter.query.get(lang, query_file), labels = labels}
  local node = get_node_at_cursor()
  local results = query_through_priors_to_root(node, opts)
  log.append({"RESULTS ", a["pr-str"](results)})
  return results
end
return {["enabled?"] = enabled_3f, ["parse!"] = parse_21, ["node->str"] = node__3estr, ["lisp-comment-node?"] = lisp_comment_node_3f, parent = parent, ["document?"] = document_3f, range = range, ["node->table"] = node__3etable, ["get-root"] = get_root, ["leaf?"] = leaf_3f, ["sym?"] = sym_3f, ["get-leaf"] = get_leaf, ["node-surrounded-by-form-pair-chars?"] = node_surrounded_by_form_pair_chars_3f, ["node-prefixed-by-chars?"] = node_prefixed_by_chars_3f, ["get-form"] = get_form, ["add-language"] = add_language, ["get-query-captures"] = get_query_captures, ["get-file-query-captures"] = get_file_query_captures}
