(local {: autoload : define} (require :conjure.nfnl.module))
(local ls (autoload :conjure.lexical-search))

(local M (define :conjure.client.common-lisp.completions))

(local locals-query "
  (defun_header
    function_name: ((sym_lit) @global.define)*
    lambda_list: 
      (list_lit
        ((sym_lit) @local.bind)*
      )
   ) 

  (defun_header
    function_name: ((sym_lit) @global.define)*
    lambda_list: 
     (list_lit
        (list_lit
          . (sym_lit) @local.bind
        )
     )
  ) 
  
  (list_lit
    .
    (sym_lit) @_defvar
    .
    (sym_lit) @global.define
    (#match? @_defvar \"^(cl:)?(defvar|defparameter|defconstant|defsetf)$\"))
   
  (list_lit
    .
    (sym_lit) @_deftest
    .
    (sym_lit) @global.define
    (#eq? @_deftest \"deftest\"))
   
  (for_clause
    .
    (sym_lit) @local.bind
  )

  (with_clause
    .
    (sym_lit) @local.bind
  )

  (list_lit
    . (sym_lit) @_d
    . (list_lit . (sym_lit) @local.bind)
    (#any-of? @_d \"do\" \"dotimes\"))

  (list_lit
    . (sym_lit) @_db
    . (list_lit ((sym_lit) @local.bind)*)
    (#any-of? @_db \"destructuring-bind\" \"multiple-value-bind\"))

  (list_lit
    . (sym_lit) @_l
    . (list_lit
       (list_lit . (sym_lit) @local.bind))
    (#any-of? @_l \"let\" \"let*\"))

  (list_lit
    . (sym_lit) @_l
    . (list_lit
       (list_lit 
         . (sym_lit) @local.bind
         . (list_lit (sym_lit) @local.bind)))
    (#any-of? @_l \"flet\" \"labels\" \"macrolet\"))

  (list_lit
    . (sym_lit) @_dc
    . (sym_lit) @global.define
  (#any-of? @_dc \"defclass\" \"defstruct\"))
")



(fn M.get-lexical-completions []
  (ls.get-lexical-captures-for-query
    :commonlisp
    locals-query))

M
