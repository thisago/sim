## Data visualization

from std/os import splitFile

import sim/base

proc viewFile(file: string; lang: DataType) =
  let filename = getFilename file
  showFile filename, lang
  echo lang

proc view*(files: seq[string]; lang = $dtUnknown) =
  ## Parse and pretty view data of files
  for file in files:
    var language: DataType
    if lang == $dtUnknown:
      let parts = splitFile file
      language = parseDataType parts.ext
    else:
      language = parseDataType lang
    file.viewFile language
