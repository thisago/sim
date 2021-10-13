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

# from std/json import JsonNode, `{}`, hasKey, newJArray, newJObject, `{}=`,
#                      `%`, `[]`
# from std/json import `$`
import std/json
from std/strutils import split, parseInt

func parseKeys*(selector: string): seq[string] =
  result = selector.split selectorSplitter

func isNumber(val: string): tuple[isNum: bool; val: int] =
  ## TODO: Do it in another way
  try:
    result.val = parseInt val
    result.isNum = true
  except:
    result.isNum = false

func hasKey(node: JsonNode; key: int): bool =
  ## Checks if array has given index
  try:
    discard node[key]
    result = true
  except:
    result = false

func get(node: JsonNode; keys: seq[string]): JsonNode =
  result = node
  for key in keys:
    let num = isNumber key
    if num.isNum:
      result = result{num.val}
    else:
      result = result{key}

proc setVal*(node: JsonNode, key: int, value: JsonNode) =
  assert(node.kind == JArray)
  if node.len >= key:
    node[$key] = value
  else:
    node.add value

proc `{}=`*(node: JsonNode, key: int, value: JsonNode) =
  ## Traverses the node and tries to set the value at the given location
  ## to `value`. If any of the keys are missing, they are added.
  var node = node
  node.setVal key, value

func setVal*(data: var JsonNode; keys: seq[string]; value: string) =
  var validKeys: seq[string]
  for i, key in keys:
    let
      num = isNumber key
      currNode = data.get validKeys
    if keys.len == i + 1:
      if num.isNum:
        raise newException(ValueError,
          "Cannot set array index, to add, use '-k object.array -v newItem' to add new item to `object.array`")
      else:
        if currNode{key}.kind == JArray:
          data.get(validKeys){key}.add %value
        else:
          data.get(validKeys){key} = %value
    else:
      if key != wildcardSelector:
        var hasKey = false
        if num.isNum:
          if currNode.hasKey num.val:
            hasKey = true
            validKeys.add key
        else:
          if currNode.hasKey key:
            hasKey = true
            validKeys.add key
        if not hasKey:
          if keys.len > i + 1:
            data.get(validKeys){key} =
              if isNumber(keys[i + 1]).isNum: newJArray()
              else: newJObject()
  # data.get(validKeys[0..^2]){validKeys[^1]} = %value
