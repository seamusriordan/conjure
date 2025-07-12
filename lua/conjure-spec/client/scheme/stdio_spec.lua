-- [nfnl] fnl/conjure-spec/client/scheme/stdio_spec.fnl
local _local_1_ = require("plenary.busted")
local describe = _local_1_["describe"]
local it = _local_1_["it"]
local spy = _local_1_["spy"]
local assert = require("luassert.assert")
local stdio = require("conjure.client.scheme.stdio")
local config = require("conjure.config")
local mock_tsc = require("conjure-spec.mock-tree-sitter-completions")
local mock_log = require("conjure-spec.mock-log")
package.loaded["conjure.tree-sitter-completions"] = mock_tsc
package.loaded["conjure.log"] = mock_log
local function _2_()
  local function _3_()
    local function _4_()
      local completion_results = {}
      local completion_callback
      local function _5_(res)
        return table.insert(completion_results, res)
      end
      completion_callback = _5_
      mock_tsc["set-mock-completions"]({})
      stdio.completions({prefix = "dela", cb = completion_callback})
      return assert.same({"delay"}, completion_results[1])
    end
    it("returns delay for prefix dela when no treesitter completions", _4_)
    local function _6_()
      local completion_results = {}
      local completion_callback
      local function _7_(res)
        return table.insert(completion_results, res)
      end
      completion_callback = _7_
      mock_tsc["set-mock-completions"]({"delta", "other"})
      stdio.completions({prefix = "delt", cb = completion_callback})
      return assert.same({"delta"}, completion_results[1])
    end
    it("returns delta for prefix delt when treesitter completion delta and other", _6_)
    local function _8_()
      local completion_results = {}
      local completion_callback
      local function _9_(res)
        return table.insert(completion_results, res)
      end
      completion_callback = _9_
      mock_tsc["set-mock-completions"]({"delay-more"})
      stdio.completions({prefix = "dela", cb = completion_callback})
      return assert.same({"delay-more", "delay"}, completion_results[1])
    end
    return it("returns delay-more and delay for prefix dela when treesitter completion delay-more", _8_)
  end
  describe("completions", _3_)
  local function _10_()
    local function _11_()
      config.merge({client = {scheme = {stdio = {enable_completions = false}}}}, {["overwrite?"] = true})
      local completion_results = {}
      local completion_callback
      local function _12_(res)
        return table.insert(completion_results, res)
      end
      completion_callback = _12_
      mock_tsc["set-mock-completions"]({"delay"})
      stdio.completions({prefix = "dela", cb = completion_callback})
      return assert.same({}, completion_results[1])
    end
    it("returns empty list for completions when completions disabled", _11_)
    local function _13_()
      config.merge({client = {scheme = {stdio = {enable_completions = true}}}}, {["overwrite?"] = true})
      local completion_results = {}
      local completion_callback
      local function _14_(res)
        return table.insert(completion_results, res)
      end
      completion_callback = _14_
      mock_tsc["set-mock-completions"]({"delay-more"})
      stdio.completions({prefix = "dela", cb = completion_callback})
      return assert.same({"delay-more", "delay"}, completion_results[1])
    end
    return it("returns delay delay-more for completions when completions enabled and tree sitter completion delay-more", _13_)
  end
  return describe("config", _10_)
end
return describe("conjure.client.scheme.stdio", _2_)
