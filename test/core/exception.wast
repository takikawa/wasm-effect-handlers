;; Test `exception` declarations.

(module
  (type (func))
  (type (func (param i32) (param i64) (result)))

  (exception (type 0))
  (exception $1 (type 1))
  (exception (export "Not_found") (type 0))
  (export "fail" (exception 0))
)
