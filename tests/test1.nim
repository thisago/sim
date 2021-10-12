import std/unittest
import ./sim

suite "sim":
  test "Can say":
    const msg = "Hello from sim test"
    check msg == say msg
