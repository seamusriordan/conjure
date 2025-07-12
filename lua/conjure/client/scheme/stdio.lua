-- [nfnl] fnl/conjure/client/scheme/stdio.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local a = autoload("conjure.aniseed.core")
local str = autoload("conjure.aniseed.string")
local stdio = autoload("conjure.remote.stdio")
local config = autoload("conjure.config")
local text = autoload("conjure.text")
local mapping = autoload("conjure.mapping")
local client = autoload("conjure.client")
local log = autoload("conjure.log")
local ts = autoload("conjure.tree-sitter")
local cmpl = autoload("conjure.client.scheme.completions")
local M = define("conjure.client.scheme.stdio")
config.merge({client = {scheme = {stdio = {command = "mit-scheme", prompt_pattern = "[%]e][=r]r?o?r?> ", value_prefix_pattern = "^;Value: ", enable_completions = true}}}})
if config["get-in"]({"mapping", "enable_defaults"}) then
  config.merge({client = {scheme = {stdio = {mapping = {start = "cs", stop = "cS", interrupt = "ei"}}}}})
else
end
local cfg = config["get-in-fn"]({"client", "scheme", "stdio"})
local state
local function _3_()
  return {repl = nil}
end
state = client["new-state"](_3_)
M["buf-suffix"] = ".scm"
M["comment-prefix"] = "; "
M["form-node?"] = ts["node-surrounded-by-form-pair-chars?"]
local function with_repl_or_warn(f, opts)
  local repl = state("repl")
  if repl then
    return f(repl)
  else
    return log.append({(M["comment-prefix"] .. "No REPL running")})
  end
end
M.unbatch = function(msgs)
  local function _5_(_241)
    return (a.get(_241, "out") or a.get(_241, "err"))
  end
  return {out = str.join("", a.map(_5_, msgs))}
end
M["format-msg"] = function(msg)
  local function _6_(_241)
    return not str["blank?"](_241)
  end
  local function _7_(line)
    if not cfg({"value_prefix_pattern"}) then
      return line
    elseif string.match(line, cfg({"value_prefix_pattern"})) then
      return string.gsub(line, cfg({"value_prefix_pattern"}), "")
    else
      return (M["comment-prefix"] .. "(out) " .. line)
    end
  end
  return a.filter(_6_, a.map(_7_, str.split(string.gsub(string.gsub(a.get(msg, "out"), "^%s*", ""), "%s+%d+%s*$", ""), "\n")))
end
M["eval-str"] = function(opts)
  local function _9_(repl)
    local function _10_(msgs)
      local msgs0 = M["format-msg"](M.unbatch(msgs))
      opts["on-result"](a.last(msgs0))
      return log.append(msgs0)
    end
    return repl.send((opts.code .. "\n"), _10_, {["batch?"] = true})
  end
  return with_repl_or_warn(_9_)
end
M["eval-file"] = function(opts)
  return M["eval-str"](a.assoc(opts, "code", ("(load \"" .. opts["file-path"] .. "\")")))
end
local function display_repl_status(status)
  return log.append({(M["comment-prefix"] .. cfg({"command"}) .. " (" .. (status or "no status") .. ")")}, {["break?"] = true})
end
M.stop = function()
  local repl = state("repl")
  if repl then
    repl.destroy()
    display_repl_status("stopped")
    return a.assoc(state(), "repl", nil)
  else
    return nil
  end
end
M.start = function()
  if state("repl") then
    return log.append({(M["comment-prefix"] .. "Can't start, REPL is already running."), (M["comment-prefix"] .. "Stop the REPL with " .. config["get-in"]({"mapping", "prefix"}) .. cfg({"mapping", "stop"}))}, {["break?"] = true})
  else
    local function _12_()
      return display_repl_status("started")
    end
    local function _13_(err)
      return display_repl_status(err)
    end
    local function _14_(code, signal)
      if (("number" == type(code)) and (code > 0)) then
        log.append({(M["comment-prefix"] .. "process exited with code " .. code)})
      else
      end
      if (("number" == type(signal)) and (signal > 0)) then
        log.append({(M["comment-prefix"] .. "process exited with signal " .. signal)})
      else
      end
      return M.stop()
    end
    local function _17_(msg)
      return log.append(M["format-msg"](msg))
    end
    return a.assoc(state(), "repl", stdio.start({["prompt-pattern"] = cfg({"prompt_pattern"}), cmd = cfg({"command"}), ["on-success"] = _12_, ["on-error"] = _13_, ["on-exit"] = _14_, ["on-stray-output"] = _17_}))
  end
end
M.interrupt = function()
  local function _19_(repl)
    log.append({(M["comment-prefix"] .. " Sending interrupt signal.")}, {["break?"] = true})
    return repl["send-signal"]("sigint")
  end
  return with_repl_or_warn(_19_)
end
M["on-load"] = function()
  return M.start()
end
M["on-filetype"] = function()
  mapping.buf("SchemeStart", cfg({"mapping", "start"}), M.start, {desc = "Start the REPL"})
  mapping.buf("SchemeStop", cfg({"mapping", "stop"}), M.stop, {desc = "Stop the REPL"})
  return mapping.buf("SchemeInterrupt", cfg({"mapping", "interrupt"}), M.interrupt, {desc = "Interrupt the REPL"})
end
M["on-exit"] = function()
  return M.stop()
end
local function completions_enabled_3f()
  return cfg({"enable_completions"})
end
M.completions = function(opts)
  if completions_enabled_3f() then
    local all_completions = cmpl["get-completions"]()
    local prefix_pattern = ("^" .. opts.prefix)
    local prefix_filter
    local function _20_(s)
      return string.match(s, prefix_pattern)
    end
    prefix_filter = _20_
    local suggestions = a.filter(prefix_filter, all_completions)
    return opts.cb(suggestions)
  else
    return opts.cb({})
  end
end
return M
