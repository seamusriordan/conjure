(list 
  . (symbol) @_d
  . (list
      . (symbol) @local.define
      [
       ((symbol) @local.bind)
       (list . (symbol) @local.bind)
       (keyword)
       ]*)
  (#any-of? @_d "define" "define*"))
@local.scope

(list
  . (symbol) @_l
  . (list
      [
       ((symbol) @local.bind)
       (list . (symbol) @local.bind)
       (keyword)
       ]*) 
  (#any-of? @_l "lambda" "lambda*"))
@local.scope

(list
  . (symbol) @_d
  . (symbol) @local.define
  (#any-of? @_d "define" "define-syntax"))
@local.scope

(list
  . (symbol) @_l
  . (list
      (list . (symbol) @local.bind))
  (#any-of? @_l "let" "let*" "let-syntax" "letrec" "letrec-syntax"))
@local.scope

(list
  . (symbol) @_sr
  . (list)
  . (list ; square bracket
      (list
        . (_) (symbol)* @local.bind))*
  (#eq? @_sr "syntax-rules"))
@local.scope

(list
  . (symbol) @_l
  . (list
      (list . (list (symbol) @local.bind)))
  (#any-of? @_l "let-values" "let*-values"))
@local.scope

;; named let
(list
  . (symbol) @_l
  . (symbol) @local.bind
  . (list
      (list . (symbol) @local.bind))
  (#any-of? @_l "let" "let*" "letrec"))
@local.scope

(list
  . (symbol) @_do
  . (list
      (list . (symbol) @local.bind))
  (#any-of? @_do "do"))
@local.scope

