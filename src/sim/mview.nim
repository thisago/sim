## Data visualization

from std/os import splitFile

import sim/base
import sim/serialize

proc viewFile(file: string; format, previewLang: DataFormat) =
  if not valid file:
    return
  let filename = getFilename file
  showFile filename, format
  let data = file.readFile.deserialize format
  data.show previewLang

proc view*(files: seq[string]; lang = $dfUnknown; previewLang = $dfJson) =
  ## Parse and pretty view data of files
  for file in files:
    file.viewFile getLang(file, lang), parseDataFormat previewLang
