## Data visualization

from std/strutils import toLowerAscii, parseEnum, toUpperAscii
from std/os import splitFile
from std/terminal import styledEcho, fgGreen, styleDim, styledWriteLine,
                         fgDefault

type
  DataType* = enum
    dtUnknown = "unknown", dtJson = "json",
      dtYaml = "yaml", dtToml = "toml",
      dtXml = "xml"

func identifyType*(ext: string): string =
  result = $dtUnknown
  if ext.len > 0:
    var dataName = ext
    if ext[0] == '.':
      dataName = ext[1..^1]
    for dt in DataType:
      let name = $dt
      if dataName == name:
        result = name

func parseDataType*(s: string): DataType =
  result = dtUnknown
  try:
    result = parseEnum[DataType](toLowerAscii s)
  except:
    discard

func toTileCase*(s: string): string =
  result = toUpperAscii $s[0]
  result.add s[1..^1].toLowerAscii

func pretty*(dt: DataType): string =
  ## Pretty `DataType`
  case dt:
  of dtUnknown: toTileCase $dtUnknown
  else:
    toUpperAscii $dt

func getFilename*(file: string): string =
  ## Extract file name and extension from full/relative path
  let parts = splitFile file
  result = parts.name & parts.ext

proc showFile*(filename: string; dt: DataType) =
  ## Displays the filename and type with `styledEcho`
  styledEcho fgGreen, filename, " ", fgDefault, styleDim, dt.pretty
