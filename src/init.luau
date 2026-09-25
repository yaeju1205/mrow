const parser = require("./src/parser")
const result = require("./src/result")

const mrow = {}

mrow.parser = parser
mrow.result = result

mrow.string = require("./src/parser_atomic/string")
mrow.satisfy = require("./src/parser_atomic/satisfy")
mrow.any = require("./src/parser_atomic/any")
mrow.one_of = require("./src/parser_atomic/one_of")
mrow.none_of = require("./src/parser_atomic/none_of")
mrow.spaces = require("./src/parser_atomic/spaces")
mrow.eof = require("./src/parser_atomic/eof")

mrow.natural = require("./src/parser_primitive/natural_number")
mrow.integer = require("./src/parser_primitive/integer")

mrow.choice = require("./src/parser_combinate/choice")
mrow.sequence = require("./src/parser_combinate/sequence")
mrow.many = require("./src/parser_combinate/many")
mrow.some = require("./src/parser_combinate/some")
mrow.optional = require("./src/parser_combinate/optional")
mrow.map = require("./src/parser_combinate/map")
mrow.between = require("./src/parser_combinate/between")
mrow.separated = require("./src/parser_combinate/separated")
mrow.token = require("./src/parser_combinate/token")
mrow.lazy = require("./src/parser_combinate/lazy")
mrow.label = require("./src/parser_combinate/label")

export type Parser<T...> = parser.Parser<T...>
export type ParserData = parser.ParserData
export type ParserState = parser.ParserState
export type ParserError = parser.ParserError
export type ParserErrors = parser.ParserErrors
export type ParserResult<T...> = parser.ParserResult<T...>

function mrow.parse<T...>(input: string, target: parser.Parser<T...>): parser.ParserResult<T...>
    const data = parser.load_data(input)

    const parsed = target(data)
    if parsed.failed then
        return parsed
    end

    const rest = mrow.eof(data)
    if rest.failed then
        return rest
    end

    return parsed
end

function mrow.parse_partial<T...>(input: string, target: parser.Parser<T...>): parser.ParserResult<T...>
    return target(parser.load_data(input))
end

return mrow
