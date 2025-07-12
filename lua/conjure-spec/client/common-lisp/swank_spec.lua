-- [nfnl] fnl/conjure-spec/client/common-lisp/swank_spec.fnl
local _local_1_ = require("plenary.busted")
local describe = _local_1_["describe"]
local it = _local_1_["it"]
local spy = _local_1_["spy"]
local before_each = _local_1_["before_each"]
local a = require("conjure.nfnl.core")
local assert = require("luassert.assert")
local swank = require("conjure.client.common-lisp.swank")
local config = require("conjure.config")
require("conjure-spec.assertions")
local mock_tsc = require("conjure-spec.mock-tree-sitter-completions")
local mock_remote = require("conjure-spec.remote.mock-swank")
local mock_log = require("conjure-spec.mock-log")
package.loaded["conjure.remote.swank"] = mock_remote
package.loaded["conjure.tree-sitter-completions"] = mock_tsc
package.loaded["conjure.log"] = mock_log
local function format_swank_return(output)
  local formatted_output = string.sub(a["pr-str"](output), 2, -2)
  return string.format("(:return (:ok (\"\" \"(%s)\")) 0)", formatted_output)
end
local function _2_()
  local function _3_()
    return mock_remote["clear-send-calls"]()
  end
  before_each(_3_)
  local function _4_()
    local function _5_()
      local completion_cb_calls = {}
      local completion_cb
      local function _6_(res)
        return table.insert(completion_cb_calls, res)
      end
      completion_cb = _6_
      mock_tsc["set-mock-completions"]({})
      swank.completions({prefix = "", cb = completion_cb})
      return assert.same({}, completion_cb_calls[1])
    end
    it("returns empty list when not connected and no treesitter completions", _5_)
    local function _7_()
      local completion_cb_calls = {}
      local completion_cb
      local function _8_(res)
        return table.insert(completion_cb_calls, res)
      end
      completion_cb = _8_
      mock_tsc["set-mock-completions"]({})
      swank.connect({})
      swank.completions({prefix = "def", cb = completion_cb})
      a["get-in"](mock_remote["send-calls"], {2, "cb"})(format_swank_return("(\"defun\") \"def\""))
      swank.disconnect()
      assert["has-substring"]("swank:simple%-completions \\\"def\\\"", a["get-in"](mock_remote["send-calls"], {2, "msg"}))
      return assert.same({"defun"}, completion_cb_calls[1])
    end
    it("returns defun when connected and swank completions returns defun and no treesitter completions", _7_)
    local function _9_()
      local completion_cb_calls = {}
      local completion_cb
      local function _10_(res)
        return table.insert(completion_cb_calls, res)
      end
      completion_cb = _10_
      mock_tsc["set-mock-completions"]({"defunct"})
      swank.connect({})
      swank.completions({prefix = "def", cb = completion_cb})
      a["get-in"](mock_remote["send-calls"], {2, "cb"})(format_swank_return("(\"defun\") \"def\""))
      swank.disconnect()
      return assert.same({"defunct", "defun"}, completion_cb_calls[1])
    end
    it("returns defunct defun when connected and swank completions returns defun and treesitter completions returns defunct", _9_)
    local function _11_()
      local completion_cb_calls = {}
      local completion_cb
      local function _12_(res)
        return table.insert(completion_cb_calls, res)
      end
      completion_cb = _12_
      mock_tsc["set-mock-completions"]({"defunct"})
      swank.completions({prefix = "def", cb = completion_cb})
      assert.same({}, mock_remote["send-calls"])
      return assert.same({"defunct"}, completion_cb_calls[1])
    end
    it("returns defunct when not connected and treesitter completions returns defunct", _11_)
    local function _13_()
      local completion_cb_calls = {}
      local completion_cb
      local function _14_(res)
        return table.insert(completion_cb_calls, res)
      end
      completion_cb = _14_
      mock_tsc["set-mock-completions"]({"symbol"})
      swank.connect({})
      swank.completions({prefix = "s", cb = completion_cb})
      a["get-in"](mock_remote["send-calls"], {2, "cb"})(format_swank_return("(\"symbol\") \"s\""))
      swank.disconnect()
      return assert.same({"symbol"}, completion_cb_calls[1])
    end
    return it("returns symbol when connected and swank completions returns symbol and treesitter completions returns symbol", _13_)
  end
  describe("completions", _4_)
  local function _15_()
    local function _16_()
      config.merge({client = {common_lisp = {swank = {enable_completions = false}}}}, {["overwrite?"] = true})
      local completion_cb_calls = {}
      local completion_cb
      local function _17_(res)
        return table.insert(completion_cb_calls, res)
      end
      completion_cb = _17_
      mock_tsc["set-mock-completions"]({"something"})
      swank.connect({})
      swank.completions({prefix = "s", cb = completion_cb})
      swank.disconnect()
      assert.are.equal(1, #mock_remote["send-calls"])
      return assert.same({}, completion_cb_calls[1])
    end
    it("returns no completions when connected and completions disabled", _16_)
    local function _18_()
      config.merge({client = {common_lisp = {swank = {enable_completions = true}}}}, {["overwrite?"] = true})
      local completion_cb_calls = {}
      local completion_cb
      local function _19_(res)
        return table.insert(completion_cb_calls, res)
      end
      completion_cb = _19_
      mock_tsc["set-mock-completions"]({"dots"})
      swank.connect({})
      swank.completions({prefix = "dot", cb = completion_cb})
      a["get-in"](mock_remote["send-calls"], {2, "cb"})(format_swank_return("(\"dotimes\") \"dot\""))
      swank.disconnect()
      return assert.same({"dots", "dotimes"}, completion_cb_calls[1])
    end
    return it("returns completions dots dotimes when connected with tree sitter results dots and completions enabled", _18_)
  end
  return describe("config", _15_)
end
return describe("conjure.client.common-lisp.swank", _2_)
