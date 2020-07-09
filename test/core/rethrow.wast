;; Test `rethrow` operator

(module
  (type (func))
  (exception $exn (type 0))

  (func (export "basic-rethrow") (result i32)
    (try (result i32)
      (do
        (try
          (do (throw 0))
          (catch rethrow))
        (i32.const 1))
      (catch
        drop
        (i32.const 27))))

  (func (export "trap-on-nullref") (local exnref)
    (block
      (local.get 0)
      (br_on_exn 0 $exn)
      drop)
  )
)

(assert_return (invoke "basic-rethrow") (i32.const 27))
(assert_trap (invoke "trap-on-nullref") "cannot use null exnref")