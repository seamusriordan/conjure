-- [nfnl] fnl/conjure-spec/client/guile/socket_spec.fnl
local _local_1_ = require("plenary.busted")
local describe = _local_1_["describe"]
local it = _local_1_["it"]
local before_each = _local_1_["before_each"]
local assert = require("luassert.assert")
local guile = require("conjure.client.guile.socket")
local config = require("conjure.config")
require("conjure-spec.assertions")
local mock_socket = require("conjure-spec.client.guile.mock-socket")
local mock_tsc = require("conjure-spec.mock-tree-sitter-completions")
local mock_log = require("conjure-spec.mock-log")
package.loaded["conjure.remote.socket"] = mock_socket
package.loaded["conjure.tree-sitter-completions"] = mock_tsc
package.loaded["conjure.log"] = mock_log
local completion_code_define_match = "%(define%* %(%%conjure:get%-guile%-completions"
local function set_repl_connected(repl)
  repl["status"] = "connected"
  return nil
end
local function _2_()
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
    local function _23_()
      return config.merge({client = {guile = {socket = {pipename = "fake-pipe", host_port = nil}}}}, {["overwrite?"] = true})
    end
    before_each(_23_)
    local function _24_()
      local calls = {}
      local spy_send
      local function _25_(call)
        return table.insert(calls, call)
      end
      spy_send = _25_
      local mock_repl = mock_socket["build-mock-repl"](spy_send)
      local callback_results = {}
      local mock_callback
      local function _26_(result)
        return table.insert(callback_results, result)
      end
      mock_callback = _26_
      mock_socket["set-mock-repl"](mock_repl)
      guile.completions({cb = mock_callback, prefix = "something"})
      assert.same({}, calls)
      return assert.same({}, callback_results[1])
    end
    it("Does not execute completions in REPL when not connected", _24_)
    local function _27_()
      local calls = {}
      local spy_send
      local function _28_(call)
        return table.insert(calls, call)
      end
      spy_send = _28_
      local mock_repl = mock_socket["build-mock-repl"](spy_send)
      local callback_results = {}
      local mock_callback
      local function _29_(result)
        return table.insert(callback_results, result)
      end
      mock_callback = _29_
      mock_socket["set-mock-repl"](mock_repl)
      guile.completions({cb = mock_callback, prefix = "define"})
      return assert.same("define", callback_results[1][1])
    end
    it("Gets built-in results for define when execute completions and REPL not connected", _27_)
    local function _30_()
      local calls = {}
      local spy_send
      local function _31_(call, callback)
        return table.insert(calls, {code = call, callback = callback})
      end
      spy_send = _31_
      local mock_repl
      local function _32_()
      end
      mock_repl = {send = spy_send, status = nil, destroy = _32_}
      local callback_results = {}
      local mock_callback
      local function _33_(result)
        return table.insert(callback_results, result)
      end
      mock_callback = _33_
      mock_socket["set-mock-repl"](mock_repl)
      guile.connect({})
      set_repl_connected(mock_repl)
      guile.completions({cb = mock_callback, prefix = "dela"})
      local completion_call = calls[3]
      completion_call.callback({{out = "(\"dela-something\")"}})
      guile.disconnect()
      return assert.same({"delay", "dela-something"}, callback_results[1])
    end
    it("Executes completions in REPL for prefix dela with result delay and dela-something", _30_)
    local function _34_()
      local calls = {}
      local spy_send
      local function _35_(call, callback)
        return table.insert(calls, {code = call, callback = callback})
      end
      spy_send = _35_
      local mock_repl
      local function _36_()
      end
      mock_repl = {send = spy_send, status = nil, destroy = _36_}
      local callback_results = {}
      local mock_callback
      local function _37_(result)
        return table.insert(callback_results, result)
      end
      mock_callback = _37_
      mock_tsc["set-mock-completions"]({"delalex"})
      mock_socket["set-mock-repl"](mock_repl)
      guile.connect({})
      set_repl_connected(mock_repl)
      guile.completions({cb = mock_callback, prefix = "dela"})
      calls[3].callback({{out = "(\"dela-something\")"}})
      guile.disconnect()
      return assert.same({"delalex", "delay", "dela-something"}, callback_results[1])
    end
    it("Executes completions with lexical results given prefix dela with result delay dela-something and delalex", _34_)
    local function _38_()
      local calls = {}
      local spy_send
      local function _39_(call, callback)
        return table.insert(calls, {code = call, callback = callback})
      end
      spy_send = _39_
      local mock_repl
      local function _40_()
      end
      mock_repl = {send = spy_send, status = nil, destroy = _40_}
      local expected_code = "%(%%conjure:get%-guile%-completions \"dela\"%)"
      local callback_results = {}
      local mock_callback
      local function _41_(result)
        return table.insert(callback_results, result)
      end
      mock_callback = _41_
      mock_tsc["set-mock-completions"]({"delay"})
      mock_socket["set-mock-repl"](mock_repl)
      guile.connect({})
      set_repl_connected(mock_repl)
      guile.completions({cb = mock_callback, prefix = "dela"})
      calls[3].callback({{out = "(\"delay\")"}})
      guile.disconnect()
      return assert.same({"delay"}, callback_results[1])
    end
    it("Deduplicates results when built-in lexical and repl results given prefix are all delay", _38_)
    local function _42_()
      local sent_callbacks = {}
      local spy_send
      local function _43_(_, callback)
        return table.insert(sent_callbacks, callback)
      end
      spy_send = _43_
      local mock_repl = mock_socket["build-mock-repl"](spy_send)
      local callback_results = {}
      local mock_callback
      local function _44_(result)
        return table.insert(callback_results, result)
      end
      mock_callback = _44_
      mock_socket["set-mock-repl"](mock_repl)
      guile.connect({})
      set_repl_connected(mock_repl)
      guile.completions({cb = mock_callback, prefix = "fu"})
      sent_callbacks[3]({{out = "(\"fun\" \"func\" \"future\")"}})
      guile.disconnect()
      return assert.same({"future", "fun", "func"}, callback_results[1])
    end
    return it("Puts last completion first for prefix fu with results fun func and future", _42_)
  end
  describe("completions", _22_)
  local function _45_()
    local function _46_()
      config.merge({client = {guile = {socket = {pipename = "fake-pipe", host_port = nil, enable_completions = false}}}}, {["overwrite?"] = true})
      local calls = {}
      local spy_send
      local function _47_(call)
        return table.insert(calls, call)
      end
      spy_send = _47_
      local mock_repl
      local function _48_()
      end
      mock_repl = {send = spy_send, status = nil, destroy = _48_}
      local expected_code = "(print \"Hello world\")"
      mock_socket["set-mock-repl"](mock_repl)
      guile.connect({})
      set_repl_connected(mock_repl)
      guile["eval-str"]({code = expected_code, context = nil})
      guile.disconnect()
      assert.are.equal(",m (guile-user)\n,import (guile)", calls[1])
      return assert.are.equal((",m (guile-user)\n" .. expected_code), calls[2])
    end
    it("Does not load completion code when completions disabled in config", _46_)
    local function _49_()
      config.merge({client = {guile = {socket = {pipename = "fake-pipe", host_port = nil, enable_completions = true}}}}, {["overwrite?"] = true})
      local calls = {}
      local spy_send
      local function _50_(call)
        return table.insert(calls, call)
      end
      spy_send = _50_
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
    it("Does load completion code when completions enabled in config", _49_)
    local function _51_()
      config.merge({client = {guile = {socket = {pipename = "fake-pipe", host_port = nil, enable_completions = false}}}}, {["overwrite?"] = true})
      local calls = {}
      local spy_send
      local function _52_(call)
        return table.insert(calls, call)
      end
      spy_send = _52_
      local mock_repl
      local function _53_()
      end
      mock_repl = {send = spy_send, status = nil, destroy = _53_}
      local callback_results = {}
      local mock_callback
      local function _54_(result)
        return table.insert(callback_results, result)
      end
      mock_callback = _54_
      mock_socket["set-mock-repl"](mock_repl)
      guile.connect({})
      set_repl_connected(mock_repl)
      guile.completions({cb = mock_callback, prefix = "define"})
      guile.disconnect()
      assert.same({}, calls)
      return assert.same({}, callback_results[1])
    end
    return it("Does not execute completions in REPL when connected but completions disabled", _51_)
  end
  return describe("enable completions config setting", _45_)
end
return describe("conjure.client.guile.socket", _2_)
