-- [nfnl] fnl/conjure-spec/fake-lexical-search.fnl
local fake_search_results = {}
local function set_fake_search_results(r)
  fake_search_results = r
  return nil
end
local function get_lexical_captures(_, _0)
  return fake_search_results
end
return {["get-lexical-captures"] = get_lexical_captures, ["set-fake-search-results"] = set_fake_search_results}
