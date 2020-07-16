open Types
open Values

type t = Exception of exn * func_type
type package = t * value list

let alloc xt =
  let exception E in
  Exception (E, xt)

let type_of (Exception (_, xt)) = xt
