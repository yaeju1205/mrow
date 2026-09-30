const parser_data = require("@self/parser_data")
const parser_result = require("@self/parser_result")
const parser_store = require("@self/parser_store")
const parser_stream = require("@self/parser_stream")

export type ParserPosition = parser_data.ParserPosition
export type ParserData = parser_data.ParserData

export type ParserError = parser_result.ParserError
export type ParserSuccess<T...> = parser_result.ParserSuccess<T...>
export type ParserFailed = parser_result.ParserFailed
export type ParserResult<T...> = parser_result.ParserResult<T...>

export type Parser<T...> = (ParserData) -> ParserResult<T...>

const parser = {}

parser.load_data = parser_data.load_data

parser.unwrap = parser_result.unwrap
parser.success = parser_result.success
parser.format = parser_result.format
parser.fail = parser_result.fail

parser.store = parser_store.store
parser.restore = parser_store.restore

parser.peek = parser_stream.peek
parser.consume = parser_stream.consume

return parser
