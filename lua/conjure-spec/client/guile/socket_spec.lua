-- [nfnl] fnl/conjure-spec/client/guile/socket_spec.fnl
local _local_1_ = require("plenary.busted")
local describe = _local_1_["describe"]
local it = _local_1_["it"]
local spy = _local_1_["spy"]
local assert = require("luassert.assert")
local guile = require("conjure.client.guile.socket")
local config = require("conjure.config")
local mock_socket = require("conjure-spec.client.guile.mock-socket")
local mock_search = require("conjure-spec.mock-lexical-search")
local mock_tree_sitter_queries = require("conjure-spec.mock-tree-sitter-queries")
require("conjure-spec.assertions")
local completion_code_define_match = "%(define%* %(%%conjure:get%-guile%-completions"
local function set_repl_connected(repl)
  repl["status"] = "connected"
  return nil
end
local function _2_()
  package.loaded["conjure.remote.socket"] = mock_socket
  package.loaded["conjure.lexical-search"] = mock_search
  package.loaded["conjure.tree-sitter-queries"] = mock_tree_sitter_queries
  local function _3_()
    local function _4_()
      return assert.are.equal(nil, guile.context("(print \"Hello World\")"))
    end
    it("returns nil for hello world", _4_)
    local function _5_()
      return assert.are.equal("(my-module)", guile.context("(define-module (my-module))"))
    end
    it("returns (my-module) for (define-module (my-module))", _5_)
    local function _6_()
      return assert.are.equal("(my-module)", guile.context("(define-module\n(my-module))"))
    end
    it("returns (my-module) for (define-module\\n(my-module))", _6_)
    local function _7_()
      return assert.are.equal("(my-module spaces)", guile.context("(define-module ( my-module  spaces   ))"))
    end
    it("returns (my-module spaces) for (define-module ( my-module  spaces   ))", _7_)
    local function _8_()
      return assert.are.equal(nil, guile.context(";(define-module (my-module))"))
    end
    it("returns nil for ;(define-module (my-module))", _8_)
    local function _9_()
      return assert.are.equal(nil, guile.context("(define-m;odule (my-module))"))
    end
    it("returns nil for (define-m;odule (my-module))", _9_)
    local function _10_()
      return assert.are.equal("(another-module)", guile.context(";\n(define-module ( another-module ))"))
    end
    it("returns (another-module) for ;\n(define-module ( another-module ))", _10_)
    local function _11_()
      return assert.are.equal("(a-module specification)", guile.context(";\n(define-module\n;some comments\n( a-module\n; more comments\n specification))"))
    end
    return it("returns (a-module specification) for ;\\n(define-module\\n;some comments\\n( a-module\\n; more comments\\n specification))", _11_)
  end
  describe("context extraction", _3_)
  local function _12_()
    config.merge({client = {guile = {socket = {pipename = "fake-pipe", host_port = nil}}}}, {["overwrite?"] = true})
    local function _13_()
      local calls = {}
      local spy_send
      local function _14_(call)
        return table.insert(calls, call)
      end
      spy_send = _14_
      local mock_repl = mock_socket["build-mock-repl"](spy_send)
      local expected_code = "(print \"Hello world\")"
      mock_socket["set-mock-repl"](mock_repl)
      guile.connect({})
      set_repl_connected(mock_repl)
      guile["eval-str"]({code = expected_code, context = nil})
      guile.disconnect()
      assert.are.equal(",m (guile-user)\n,import (guile)", calls[1])
      assert["has-substring"](completion_code_define_match, calls[2])
      return assert.are.equal((",m (guile-user)\n" .. expected_code), calls[3])
    end
    it("initializes (guile-user) when eval-str called on new repl in nil context", _13_)
    local function _15_()
      local calls = {}
      local spy_send
      local function _16_(call)
        return table.insert(calls, call)
      end
      spy_send = _16_
      local mock_repl = mock_socket["build-mock-repl"](spy_send)
      local expected_code = "(print \"Hello second call\")"
      mock_socket["set-mock-repl"](mock_repl)
      guile.connect({})
      set_repl_connected(mock_repl)
      guile["eval-str"]({code = "(first-call)", context = nil})
      guile["eval-str"]({code = expected_code, context = nil})
      guile.disconnect()
      return assert.are.equal((",m (guile-user)\n" .. expected_code), calls[4])
    end
    it("initializes (guile-user) once when eval-str called twice on repl in nil context", _15_)
    local function _17_()
      local calls = {}
      local spy_send
      local function _18_(call)
        return table.insert(calls, call)
      end
      spy_send = _18_
      local mock_repl = mock_socket["build-mock-repl"](spy_send)
      local expected_code = "(print \"Hello second call\")"
      mock_socket["set-mock-repl"](mock_repl)
      guile.connect({})
      set_repl_connected(mock_repl)
      guile["eval-str"]({code = "(first-call)", context = nil})
      guile.disconnect()
      guile.connect({})
      set_repl_connected(mock_repl)
      guile["eval-str"]({code = expected_code, context = nil})
      guile.disconnect()
      assert.are.equal(",m (guile-user)\n,import (guile)", calls[4])
      assert["has-substring"](completion_code_define_match, calls[5])
      return assert.are.equal((",m (guile-user)\n" .. expected_code), calls[6])
    end
    it("initializes (guile-user) again when eval-str disconnect eval-str is called in nil context", _17_)
    local function _19_()
      local calls = {}
      local spy_send
      local function _20_(call)
        return table.insert(calls, call)
      end
      spy_send = _20_
      local mock_repl
      local function _21_()
      end
      mock_repl = {send = spy_send, status = nil, destroy = _21_}
      local expected_module = "a-module"
      local expected_code = "(print \"Hello second call\")"
      mock_socket["set-mock-repl"](mock_repl)
      guile.connect({})
      set_repl_connected(mock_repl)
      guile["eval-str"]({code = "(first-call)", context = nil})
      guile["eval-str"]({code = expected_code, context = expected_module})
      guile.disconnect()
      assert.are.equal((",m " .. expected_module .. "\n,import (guile)"), calls[4])
      assert["has-substring"](completion_code_define_match, calls[5])
      return assert.are.equal((",m " .. expected_module .. "\n" .. expected_code), calls[6])
    end
    return it("initializes (a-module) when eval-str in (guile-user) then eval-str in (a-module)", _19_)
  end
  describe("module initialization", _12_)
  local function _22_()
    config.merge({client = {guile = {socket = {pipename = "fake-pipe", host_port = nil}}}}, {["overwrite?"] = true})
    local function _23_()
      local calls = {}
      local spy_send
      local function _24_(call)
        return table.insert(calls, call)
      end
      spy_send = _24_
      local mock_repl = mock_socket["build-mock-repl"](spy_send)
      local callback_results = {}
      local mock_callback
      local function _25_(result)
        return table.insert(callback_results, result)
      end
      mock_callback = _25_
      mock_socket["set-mock-repl"](mock_repl)
      guile.completions({cb = mock_callback, prefix = "something"})
      assert.same({}, calls)
      return assert.same({}, callback_results[1])
    end
    it("Does not execute completions in REPL when not connected", _23_)
    local function _26_()
      local calls = {}
      local spy_send
      local function _27_(call)
        return table.insert(calls, call)
      end
      spy_send = _27_
      local mock_repl = mock_socket["build-mock-repl"](spy_send)
      local callback_results = {}
      local mock_callback
      local function _28_(result)
        return table.insert(callback_results, result)
      end
      mock_callback = _28_
      mock_socket["set-mock-repl"](mock_repl)
      guile.completions({cb = mock_callback, prefix = "define"})
      return assert.same("define", callback_results[1][1])
    end
    it("Gets built-in results for define when execute completions and REPL not connected", _26_)
    local function _29_()
      local calls = {}
      local spy_send
      local function _30_(call, callback)
        return table.insert(calls, {code = call, callback = callback})
      end
      spy_send = _30_
      local mock_repl
      local function _31_()
      end
      mock_repl = {send = spy_send, status = nil, destroy = _31_}
      local callback_results = {}
      local mock_callback
      local function _32_(result)
        return table.insert(callback_results, result)
      end
      mock_callback = _32_
      mock_socket["set-mock-repl"](mock_repl)
      guile.connect({})
      set_repl_connected(mock_repl)
      guile.completions({cb = mock_callback, prefix = "dela"})
      local completion_call = calls[3]
      completion_call.callback({{out = "(\"dela-something\")"}})
      guile.disconnect()
      return assert.same({"delay", "dela-something"}, callback_results[1])
    end
    it("Executes completions in REPL for prefix dela with result delay and dela-something", _29_)
    local function _33_()
      local calls = {}
      local spy_send
      local function _34_(call, callback)
        return table.insert(calls, {code = call, callback = callback})
      end
      spy_send = _34_
      local mock_repl
      local function _35_()
      end
      mock_repl = {send = spy_send, status = nil, destroy = _35_}
      local callback_results = {}
      local mock_callback
      local function _36_(result)
        return table.insert(callback_results, result)
      end
      mock_callback = _36_
      mock_search["set-mock-search-results"]({"delalex"})
      mock_socket["set-mock-repl"](mock_repl)
      guile.connect({})
      set_repl_connected(mock_repl)
      guile.completions({cb = mock_callback, prefix = "dela"})
      calls[3].callback({{out = "(\"dela-something\")"}})
      guile.disconnect()
      return assert.same({"delalex", "delay", "dela-something"}, callback_results[1])
    end
    it("Executes completions with lexical results given prefix dela with result delay dela-something and delalex", _33_)
    local function _37_()
      local calls = {}
      local spy_send
      local function _38_(call, callback)
        return table.insert(calls, {code = call, callback = callback})
      end
      spy_send = _38_
      local mock_repl
      local function _39_()
      end
      mock_repl = {send = spy_send, status = nil, destroy = _39_}
      local expected_code = "%(%%conjure:get%-guile%-completions \"dela\"%)"
      local callback_results = {}
      local mock_callback
      local function _40_(result)
        return table.insert(callback_results, result)
      end
      mock_callback = _40_
      mock_search["set-mock-search-results"]({"delay"})
      mock_socket["set-mock-repl"](mock_repl)
      guile.connect({})
      set_repl_connected(mock_repl)
      guile.completions({cb = mock_callback, prefix = "dela"})
      calls[3].callback({{out = "(\"delay\")"}})
      guile.disconnect()
      return assert.same({"delay"}, callback_results[1])
    end
    it("Deduplicates results when built-in lexical and repl results given prefix are all delay", _37_)
    local function _41_()
      local sent_callbacks = {}
      local spy_send
      local function _42_(_, callback)
        return table.insert(sent_callbacks, callback)
      end
      spy_send = _42_
      local mock_repl = mock_socket["build-mock-repl"](spy_send)
      local callback_results = {}
      local mock_callback
      local function _43_(result)
        return table.insert(callback_results, result)
      end
      mock_callback = _43_
      mock_socket["set-mock-repl"](mock_repl)
      guile.connect({})
      set_repl_connected(mock_repl)
      guile.completions({cb = mock_callback, prefix = "fu"})
      sent_callbacks[3]({{out = "(\"fun\" \"func\" \"future\")"}})
      guile.disconnect()
      return assert.same({"future", "fun", "func"}, callback_results[1])
    end
    return it("Puts last completion first for prefix fu with results fun func and future", _41_)
  end
  describe("completions", _22_)
  local function _44_()
    local function _45_()
      config.merge({client = {guile = {socket = {pipename = "fake-pipe", host_port = nil, enable_completions = false}}}}, {["overwrite?"] = true})
      local calls = {}
      local spy_send
      local function _46_(call)
        return table.insert(calls, call)
      end
      spy_send = _46_
      local mock_repl
      local function _47_()
      end
      mock_repl = {send = spy_send, status = nil, destroy = _47_}
      local expected_code = "(print \"Hello world\")"
      mock_socket["set-mock-repl"](mock_repl)
      guile.connect({})
      set_repl_connected(mock_repl)
      guile["eval-str"]({code = expected_code, context = nil})
      guile.disconnect()
      assert.are.equal(",m (guile-user)\n,import (guile)", calls[1])
      return assert.are.equal((",m (guile-user)\n" .. expected_code), calls[2])
    end
    it("Does not load completion code when completions disabled in config", _45_)
    local function _48_()
      config.merge({client = {guile = {socket = {pipename = "fake-pipe", host_port = nil, enable_completions = true}}}}, {["overwrite?"] = true})
      local calls = {}
      local spy_send
      local function _49_(call)
        return table.insert(calls, call)
      end
      spy_send = _49_
      local mock_repl = mock_socket["build-mock-repl"](spy_send)
      local expected_code = "(print \"Hello world\")"
      mock_socket["set-mock-repl"](mock_repl)
      guile.connect({})
      set_repl_connected(mock_repl)
      guile["eval-str"]({code = expected_code, context = nil})
      guile.disconnect()
      assert.are.equal(",m (guile-user)\n,import (guile)", calls[1])
      assert["has-substring"](completion_code_define_match, calls[2])
      return assert.are.equal((",m (guile-user)\n" .. expected_code), calls[3])
    end
    it("Does load completion code when completions enabled in config", _48_)
    local function _50_()
      config.merge({client = {guile = {socket = {pipename = "fake-pipe", host_port = nil, enable_completions = false}}}}, {["overwrite?"] = true})
      local calls = {}
      local spy_send
      local function _51_(call)
        return table.insert(calls, call)
      end
      spy_send = _51_
      local mock_repl
      local function _52_()
      end
      mock_repl = {send = spy_send, status = nil, destroy = _52_}
      local callback_results = {}
      local mock_callback
      local function _53_(result)
        return table.insert(callback_results, result)
      end
      mock_callback = _53_
      mock_socket["set-mock-repl"](mock_repl)
      guile.connect({})
      set_repl_connected(mock_repl)
      guile.completions({cb = mock_callback, prefix = "define"})
      guile.disconnect()
      assert.same({}, calls)
      return assert.same({}, callback_results[1])
    end
    return it("Does not execute completions in REPL when connected but completions disabled", _50_)
  end
  return describe("enable completions config setting", _44_)
end
return describe("conjure.client.guile.socket", _2_)
