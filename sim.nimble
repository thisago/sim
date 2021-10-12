# Package

version       = "0.1.0"
author        = "HELLoSKUuLL"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 1.5.1"

# CLI
requires "cligen"

bin = @["sim"]
binDir = "build"

task build_release, "Builds the release version":
  exec "nimble -d:release build"
task build_danger, "Builds the danger version":
  exec "nimble -d:danger build"
task gen_docs, "Generates the documentation":
  exec "nim doc --project --out:docs src/sim.nim"
