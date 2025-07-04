-- [nfnl] fnl/conjure-spec/mock-lexical-search.fnl
local mock_search_results = {}
local function set_mock_search_results(r)
  mock_search_results = r
  return nil
end
local function get_lexical_captures(_, _0)
  return mock_search_results
end
return {["get-lexical-captures"] = get_lexical_captures, ["set-mock-search-results"] = set_mock_search_results}
