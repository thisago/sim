## Data visualization

from std/os import splitFile

import sim/base
import sim/serialize

proc setFile(file: string; format: DataFormat; keys: seq[string]; value: string) =
  if not valid file:
    return
  let filename = getFilename file
  showFile filename, format
  var data = file.readFile.deserialize format
  data.setVal(keys, value)

proc set*(files: seq[string]; lang = $dfUnknown; keys, value: string) =
  ## Set the value of key
  ##
  ## The keys is separed by dot ('.'); Numbers too
  ##
  ## Example:
  ##   'objects.1.name' - select name of object 1 (index is 0 based)
  ##
  ##   Wildcard (!):
  ##     'objects.!.name' - select name of all objects
  ##     'objects.1.!' - select all props of object 1
  let ks = parseKeys keys
  for file in files:
    file.setFile(getLang(file, lang), ks, value)
