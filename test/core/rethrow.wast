;; Test `rethrow` operator

(module
  (exception $exn)

  (func (export "basic-rethrow") (result i32)
    (try (result i32)
      (try
        (throw 0)
        (catch rethrow))
      (i32.const 1)
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