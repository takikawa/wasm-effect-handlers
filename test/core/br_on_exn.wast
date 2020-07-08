;; Test `br_on_exn` operator

(module
  (exception $exn-i32 (param i32))
  (exception $exn-i32-2 (param i32))
  (exception $exn-all (param i32 i64 f32 f64))

  (func (export "br-on-exn-i32") (result i32)
    (try (result i32)
      (i32.const 1)
      (catch
       (br_on_exn 0 $exn-i32)
       drop
       (i32.const 99)))
  )

  (func (export "throw-to-br-on-exn-i32") (result i32)
    (try (result i32)
      (i32.const 42)
      (throw 0)
      (catch
        (br_on_exn 0 $exn-i32)
        drop
        (i32.const 99)))
  )

  (func (export "non-matching-tag") (result i32)
    (try (result i32)
      (i32.const 42)
      (throw 1)
      (catch
        (br_on_exn 0 $exn-i32)
        drop
        (i32.const 99)))
  )

  (func (export "extract-multiple-params") (result i32)
    (try (result i32 i64 f32 f64)
      (i32.const 42)
      (i64.const 84)
      (f32.const 42.2)
      (f64.const 84.4)
      (throw 2)
      (catch
        (br_on_exn 0 $exn-all)
        drop
        (i32.const 99)
        (i64.const 999)
        (f32.const 99.9)
        (f64.const 999.9)))
    drop drop drop
  )

  (func $throw-helper (param i32 i64 f32 f64) (result i32 i64 f32 f64)
    (local.get 0)
    (local.get 1)
    (local.get 2)
    (local.get 3)
    (throw 2))
  (func (export "extract-multiple-params-call") (result i32)
    (try (result i32 i64 f32 f64)
      (i32.const 42)
      (i64.const 84)
      (f32.const 42.2)
      (f64.const 84.4)
      (call $throw-helper)
      (catch
        (br_on_exn 0 $exn-all)
        drop
        (i32.const 99)
        (i64.const 999)
        (f32.const 99.9)
        (f64.const 999.9)))
    drop drop drop
  )

  (func (export "multiple-br-on-exn") (result i32)
    (try (result i32)
      (i32.const 42)
      (throw 1)
      (catch
        (block (param exnref) (result i32)
          (br_on_exn 0 $exn-i32)
          (block (param exnref) (result i32)
            (br_on_exn 1 $exn-i32-2)
            drop
            (i32.const 99))
          (br 0))))
  )

  (func (export "null-exnref") (result i32) (local exnref)
    block $l (result i32)
      (local.get 0)
      (br_on_exn $l 0)
      drop
      (i32.const 1)
    end
  )
)

(assert_return (invoke "br-on-exn-i32") (i32.const 1))
(assert_return (invoke "throw-to-br-on-exn-i32") (i32.const 42))
(assert_return (invoke "non-matching-tag") (i32.const 99))
(assert_return (invoke "extract-multiple-params") (i32.const 42))
(assert_return (invoke "extract-multiple-params-call") (i32.const 42))
(assert_return (invoke "multiple-br-on-exn") (i32.const 42))
(assert_trap (invoke "null-exnref") "cannot use null exnref")