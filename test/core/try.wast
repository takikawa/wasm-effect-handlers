;; Test `try` and `catch` forms

(module
  (exception $exn)
  (exception $exn-i32 (param i32))
  (exception $exn-i32-i32 (param i32 i32))

  (func $throw-i32 (param i32) (result i32)
    (throw 1 (local.get 0)))
  (func $call-throw-i32 (param i32) (result i32)
    (call $throw-i32 (local.get 0)))
  (func $call-call-throw-i32 (param i32) (result i32)
    (call $call-throw-i32 (local.get 0)))

  (func (export "empty-try-catch") (result i32)
    (try nop (catch drop))
    (i32.const 0)
  )

  (func (export "try-no-throw") (result i32)
    (try (result i32)
      (i32.const 0)
      (catch
        drop
        (i32.const 1)))
  )

  (func (export "no-catch-effect") (result i32) (local i32)
    (try
      (local.set 0 (i32.const 42))
      (catch
        drop
        (local.set 0 (i32.const 99))))
    (local.get 0)
  )

  (func (export "throw-simple") (result i32)
    (try (result i32)
      (throw 1 (i32.const 42))
      (catch
        drop
        (i32.const 1)))
   )

  (func (export "throw-call") (result i32)
    (try (result i32)
      (call $throw-i32 (i32.const 42))
      (catch
        drop
        (i32.const 1)))
   )

  (func (export "throw-nested-call") (result i32)
    (try (result i32)
      (call $call-call-throw-i32 (i32.const 42))
      (catch
        drop
        (i32.const 1)))
   )

  (func (export "sequenced-try-catch") (result i32) (local i32)
    (try
      nop
      (catch
        drop
        (local.set 0 (i32.const 99))))
    (try
      (throw 0)
      (catch
        drop
        (local.set 0 (i32.const 42))))
    (local.get 0))

  (func (export "nested-try-catch") (result i32) (local i32)
    (try
      (try
        (try
          (throw 0)
          (catch
            drop
            (local.set 0 (i32.const 42))))
        (catch
          drop
          (local.set 0 (i32.const 97))))
      (catch
        drop
        (local.set 0 (i32.const 98))))
    (local.get 0))

  (func (export "br-before-throw") (result i32)
    (try (result i32)
      (i32.const 2)
      (br 0)
      (throw 0)
      (catch
        drop
        (i32.const 1)))
  )

  (func (export "try-with-params") (result i32)
    (i32.const 42)
    (try (param i32) (result i32)
      nop
      (catch
        drop
        (i32.const 99)))
  )

  (func (export "try-with-params-2") (result i32)
    (i32.const 42)
    (try (param i32) (result i32)
      (throw 1)
      (catch
        (br_on_exn 0 $exn-i32)
        drop
        (i32.const 99)))
  )

  (func (export "no-catch-on-trap") (result i32) (local i32)
    (try
      unreachable
      (catch
        drop
        (local.set 0 (i32.const 99))))
    (local.get 0)
  )
)

(assert_return (invoke "empty-try-catch") (i32.const 0))
(assert_return (invoke "try-no-throw") (i32.const 0))
(assert_return (invoke "no-catch-effect") (i32.const 42))
(assert_return (invoke "throw-simple") (i32.const 1))
(assert_return (invoke "throw-call") (i32.const 1))
(assert_return (invoke "throw-nested-call") (i32.const 1))
(assert_return (invoke "sequenced-try-catch") (i32.const 42))
(assert_return (invoke "nested-try-catch") (i32.const 42))
(assert_return (invoke "br-before-throw") (i32.const 2))
(assert_return (invoke "try-with-params") (i32.const 42))
(assert_return (invoke "try-with-params-2") (i32.const 42))
(assert_trap (invoke "no-catch-on-trap") "unreachable executed")