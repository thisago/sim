## SIM (Serialized Information Manipulator)

import sim/[
  mview,
  mset
]
export mview, mset

when isMainModule:
  import cligen
  dispatchMulti([
    view
  ], [
    mset.set
  ])
