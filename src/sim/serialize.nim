# Serialize and deserialize

from std/json import parseJson, `{}`, `{}=`, JsonNode, `$`
from pkg/parsetoml import parseFile, toJson
from pkg/yaml import initYamlParser, parse, constructJson, YamlStreamError,
                     YamlParserError, `$`

import sim/base

proc yamlToJson(data: string): JsonNode =
  try:
    var
      parser = initYamlParser true
      s = parser.parse data
    result = constructJson(s)[0]
  except YamlStreamError:
    let e = (ref YamlParserError)(getCurrentException().parent)
    echo "error occurred: " & e.msg
    echo "line: ", e.mark.line, ", column: ", e.mark.column
    echo e.lineContent
    raise e

proc deserialize*(data: string; format: DataFormat): JsonNode =
  ## Parse the data from `format`
  case format:
  of dfJson:
    result = parseJson data
  of dfYaml:
    result = yamlToJson data
  else:
    discard

proc show*(node: JsonNode; lang: DataFormat) =
  case lang:
  of dfJson:
    echo json.pretty(node, 2)
  else:
    discard
