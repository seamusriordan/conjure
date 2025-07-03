(local {: autoload : define} (require :conjure.nfnl.module))
(local ls (autoload :conjure.lexical-search))

(local M (define :conjure.client.common-lisp.completions))

(local locals-query "
  (defun_header
    function_name: ((sym_lit) @global.define)*
  )
  @local.scope

  (defun_header
    lambda_list:
      (list_lit
          (sym_lit) @local.define
          (#not-lua-match? @local.define \"^&.*\")
      )
  )
  @local.scope

  (defun_header
    lambda_list:
     (list_lit
        (list_lit
          (sym_lit) @local.define
          (#not-lua-match? @local.define \"^&.*\")
        )
     )
  )
  @local.scope

  (defun) @local.scope

  (list_lit
    .
    (sym_lit) @_defvar
    .
    (sym_lit) @global.define
    (#match? @_defvar \"^(cl:)?(defvar|defparameter|defconstant)$\"))
  @local.scope

  (list_lit
    .
    (sym_lit) @_def
    .
    (sym_lit) @global.define
    ((sym_lit) @local.bind)*
    (list_lit
       (sym_lit) @local.bind
    )*
    (list_lit
       (list_lit
         . 
         (sym_lit) @local.bind
       )
    )*
    (#match? @_def \"^(cl:)?(defsetf)$\"))
  @local.scope

  (list_lit
    .
    (sym_lit) @_deftest
    .
    (sym_lit) @global.define
    (#eq? @_deftest \"deftest\"))
  @local.scope

  (for_clause
    .
    (sym_lit) @local.bind
  )

  (with_clause
    .
    (sym_lit) @local.bind
  )

  (loop_macro)
  @local.scope

  (list_lit
    . (sym_lit) @_d
    . (list_lit . (sym_lit) @local.bind)
    (#any-of? @_d \"dotimes\"))
  @local.scope

  (list_lit
    . (sym_lit) @_d
    . (list_lit
         (list_lit
            . (sym_lit) @local.bind
         )
      )
    (#any-of? @_d \"do\" \"do*\"))
  @local.scope

  (list_lit
    . (sym_lit) @_db
    . (list_lit 
          (sym_lit) @local.bind
          (#not-lua-match? @local.bind \"^&.*\")
      )
    (#any-of? @_db \"destructuring-bind\" \"multiple-value-bind\"))
  @local.scope

  (list_lit
    . (sym_lit) @_db
    . (list_lit
        (list_lit
          . (sym_lit) @local.bind
        )
          (#not-lua-match? @local.bind \"^&.*\")
     )
    (#any-of? @_db \"destructuring-bind\" \"multiple-value-bind\"))
  @local.scope


  (list_lit
    . (sym_lit) @_l
    . (list_lit
       (list_lit . (sym_lit) @local.bind))
    (#any-of? @_l \"let\" \"let*\"))
  @local.scope

  (list_lit
    . (sym_lit) @_l
    . (list_lit
        (list_lit 
          . (sym_lit) @local.define
          . (list_lit (sym_lit) @local.bind))
        @local.scope
      )
    (#any-of? @_l \"flet\" \"labels\" \"macrolet\"))
  @local.scope

  (list_lit
    . (sym_lit) @_dc
    . (sym_lit) @global.define
  (#any-of? @_dc \"defclass\" \"defstruct\"))
  @local.scope

  (list_lit
    . (sym_lit) @_dc
    . (sym_lit)
    . (list_lit)
    . (list_lit 
        (list_lit
;          . (sym_lit) @global.define  ; need to deal with accessor, etc
;          (#set! prefix \":\")
        )
      )
    (#eq? @_dc \"defclass\"))
  @local.scope

  (list_lit
    . (sym_lit) @_ds
    . (sym_lit) 
;    . (sym_lit) @global.define* 
;    (#set! prefix \":\")
    (#eq? @_ds \"defstruct\"))
  @local.scope
")


(fn M.get-lexical-completions []
  (ls.get-lexical-captures
    :commonlisp
    locals-query))

M
