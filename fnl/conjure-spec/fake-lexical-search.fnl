(var fake-search-results [])

(fn set-fake-search-results [r]
  (set fake-search-results r))

(fn get-lexical-captures [_ _]
  fake-search-results)

{: get-lexical-captures
 : set-fake-search-results}

