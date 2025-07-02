-- [nfnl] fnl/conjure/client/common-lisp/completions.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local ls = autoload("conjure.lexical-search")
local M = define("conjure.client.common-lisp.completions")
local locals_query = "\n  (defun_header\n    function_name: ((sym_lit) @global.define)*\n    lambda_list: \n      (list_lit\n        ((sym_lit) @local.bind)*\n      )\n   ) \n\n  (defun_header\n    function_name: ((sym_lit) @global.define)*\n    lambda_list: \n     (list_lit\n        (list_lit\n          . (sym_lit) @local.bind\n        )\n     )\n  ) \n  \n  (list_lit\n    .\n    (sym_lit) @_defvar\n    .\n    (sym_lit) @global.define\n    (#match? @_defvar \"^(cl:)?(defvar|defparameter|defconstant|defsetf)$\"))\n   \n  (list_lit\n    .\n    (sym_lit) @_deftest\n    .\n    (sym_lit) @global.define\n    (#eq? @_deftest \"deftest\"))\n   \n  (for_clause\n    .\n    (sym_lit) @local.bind\n  )\n\n  (with_clause\n    .\n    (sym_lit) @local.bind\n  )\n\n  (list_lit\n    . (sym_lit) @_d\n    . (list_lit . (sym_lit) @local.bind)\n    (#any-of? @_d \"do\" \"dotimes\"))\n\n  (list_lit\n    . (sym_lit) @_db\n    . (list_lit ((sym_lit) @local.bind)*)\n    (#any-of? @_db \"destructuring-bind\" \"multiple-value-bind\"))\n\n  (list_lit\n    . (sym_lit) @_l\n    . (list_lit\n       (list_lit . (sym_lit) @local.bind))\n    (#any-of? @_l \"let\" \"let*\"))\n\n  (list_lit\n    . (sym_lit) @_l\n    . (list_lit\n       (list_lit \n         . (sym_lit) @local.bind\n         . (list_lit (sym_lit) @local.bind)))\n    (#any-of? @_l \"flet\" \"labels\" \"macrolet\"))\n\n  (list_lit\n    . (sym_lit) @_dc\n    . (sym_lit) @global.define\n  (#any-of? @_dc \"defclass\" \"defstruct\"))\n"
M["get-lexical-completions"] = function()
  return ls["get-query-captures"]("commonlisp", locals_query)
end
return M
