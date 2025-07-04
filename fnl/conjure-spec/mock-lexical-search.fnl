(var mock-search-results [])

(fn set-mock-search-results [r]
  (set mock-search-results r))

(fn get-lexical-captures [_ _]
  mock-search-results)

{: get-lexical-captures
 : set-mock-search-results}

