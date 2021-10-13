## Data visualization

from std/strutils import toLowerAscii, parseEnum, toUpperAscii
from std/os import splitFile, fileExists
from std/terminal import styledEcho, fgGreen, styleDim, styledWriteLine,
                         fgDefault, fgRed
from std/strformat import fmt

import sim/configs

type
  DataFormat* = enum
    dfUnknown = "unknown", dfJson = "json",
      dfYaml = "yaml", dfToml = "toml",
      dfXml = "xml"

func identifyType*(ext: string): string =
  result = $dfUnknown
  if ext.len > 0:
    var dataName = ext
    if ext[0] == '.':
      dataName = ext[1..^1]
    for df in DataFormat:
      let name = $df
      if dataName == name:
        result = name

func parseDataFormat*(s: string): DataFormat =
  result = dfUnknown
  try:
    result = parseEnum[DataFormat](toLowerAscii s)
  except:
    discard

func toTileCase*(s: string): string =
  result = toUpperAscii $s[0]
  result.add s[1..^1].toLowerAscii

func pretty*(df: DataFormat): string =
  ## Pretty `DataFormat`
  case df:
  of dfUnknown: toTileCase $dfUnknown
  else:
    toUpperAscii $df

func getFilename*(file: string): string =
  ## Extract file name and extension from full/relative path
  let parts = splitFile file
  result = parts.name & parts.ext

proc showFile*(filename: string; df: DataFormat) =
  ## Displays the filename and type with `styledEcho`
  styledEcho fgGreen, filename, " ", fgDefault, styleDim, df.pretty

proc valid*(file: string): bool =
  ## Checks if the given file is a valid data file
  result = true
  var err = ""

  if not fileExists file:
    err = fmt"File '{file}' not exists"

  if err.len > 0:
    result = false
    styledEcho fgRed, "Error: ", fgDefault, err

func getLang*(file, forcedLang: string): DataFormat =
  ## Returns the parsed `forcedLang` or try to infer by file ext
  if forcedLang == $dfUnknown:
    let parts = splitFile file
    result = parseDataFormat identifyType parts.ext
  else:
    result = parseDataFormat forcedLang

from std/json import JsonNode, `{}`, hasKey
from std/strutils import split, parseInt

func parseKeys*(selector: string): seq[string] =
  result = selector.split selectorSplitter

func setVal*(data: var JsonNode; keys: seq[string]; value: string) =
  var validKeys: seq[string]
  for i, key in keys:
    if key != wildcardSelector:
      if node.hasKey key:
        validKeys.add key
      else:
        if keys.len > i + 1:
          try:
            discard parseInt keys[i + 1]
            node
          except:
            discard


    debugEcho keys
