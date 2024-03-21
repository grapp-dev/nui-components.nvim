// https://github.com/yhchen/json_to_lua

let MaxPrettyExpandDepth = 0
const INIFINIT = 65536

/**
 * @description Convert js object to lua string (data only. no functional)
 * @param obj js object
 * @returns string in lua format
 */
export function jsObjectToLua(obj: any): string {
  MaxPrettyExpandDepth = 0
  return toLua(obj, 0)
}

/**
 * @description Convert json string to lua string
 * @param s json string
 * @returns string in lua format
 */
export function jsonToLua(s: string): string {
  MaxPrettyExpandDepth = 0
  const obj = JSON.parse(s)
  return toLua(obj, 0)
}

/**
 * @description Convert js object to lua string (data only. no functional)
 * @param obj js object
 * @param maxPrettyExpandDepth max pretty expand depth(level). default is 65536
 * @returns string in lua format
 */
export function jsObjectToLuaPretty(obj: any, maxPrettyExpandDepth: number = INIFINIT): string {
  MaxPrettyExpandDepth = maxPrettyExpandDepth
  return toLua(obj, 0)
}

/**
 * @description Convert json string to lua string
 * @param s json string
 * @param maxPrettyExpandDepth max pretty expand depth(level). default is 65536
 * @returns string in lua format
 */
export function jsonToLuaPretty(s: string, maxPrettyExpandDepth: number = INIFINIT): string {
  MaxPrettyExpandDepth = maxPrettyExpandDepth
  const obj = JSON.parse(s)
  return toLua(obj, 0)
}

export function makeLuaKey(s: string): string {
  const isword = isValidWord(s)
  if (parseInt(s).toString() == s) {
    return `[${s}]`
  } else if (isword) {
    return s
  }
  return `["${s}"]`
}

/**
 * Digital character set
 */
const NumberCharSet = new Set<string>(['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'])

/**
 * The first valid character set for a word
 */
const WordFirstValidCharSet = new Set<string>([
  'a',
  'b',
  'c',
  'd',
  'e',
  'f',
  'g',
  'h',
  'i',
  'j',
  'k',
  'l',
  'm',
  'n',
  'o',
  'p',
  'q',
  'r',
  's',
  't',
  'u',
  'v',
  'w',
  'x',
  'y',
  'z',
  'A',
  'B',
  'C',
  'D',
  'E',
  'F',
  'G',
  'H',
  'I',
  'J',
  'K',
  'L',
  'M',
  'N',
  'O',
  'P',
  'Q',
  'R',
  'S',
  'T',
  'U',
  'V',
  'W',
  'X',
  'Y',
  'Z',
  '_',
])

/**
 *
 * @description Check 's' is a vaild word
 * @param s input string
 * @returns true if 's' is a Valid word
 */
function isValidWord(s: string): boolean {
  for (let i = 0; i < s.length; ++i) {
    const c = s[i]
    if (i == 0) {
      if (!WordFirstValidCharSet.has(c)) return false
    } else {
      if (!WordFirstValidCharSet.has(c) && !NumberCharSet.has(c)) return false
    }
  }
  return true
}
/**
 *
 * @description convert json object to lua string
 * @param obj js object
 * @param currDepth Recursion depth
 * @param CurrEntry Current line grammar indentation format
 * @return string in lua format
 */
function toLua(obj: any, currDepth: number, CurrEntry?: string): string {
  const pretty = MaxPrettyExpandDepth > currDepth
  const NextDepth = currDepth + 1
  CurrEntry = CurrEntry != undefined && pretty ? CurrEntry + '  ' : ''
  const ObjectEntry = CurrEntry != undefined && pretty ? CurrEntry + '  ' : ''
  const EndLine = pretty ? '\n' : ''
  const WriteSpace = pretty ? ' ' : ''
  if (obj === null || obj === undefined) {
    return 'nil'
  }
  if (typeof obj !== 'object') {
    if (typeof obj === 'string') {
      return '"' + obj + '"'
    }
    return obj.toString()
  }
  let result = `{` + EndLine,
    isArray = obj instanceof Array,
    len = Object.keys(obj).length,
    i = 0
  Object.entries(obj).forEach(function ([k, v]: [string, any]) {
    let objStr = ''
    if (isArray) {
      objStr = toLua(v, NextDepth, CurrEntry)
    } else {
      objStr = `${makeLuaKey(k)}${WriteSpace}=${WriteSpace}${toLua(v, NextDepth, CurrEntry)}`
    }
    if (i < len - 1) {
      objStr += ','
    }
    i += 1
    result += ObjectEntry + objStr + EndLine
  })
  result += CurrEntry + '}'
  return result
}
