--[=[
    @class mrow

    A parser combinator library: small parsers that read one thing, and combinators
    that glue them into a grammar.

    A parser is just a function over a [ParserData] that returns a [ParserResult] —
    either the values it read, or the errors explaining why it could not. Parsers
    never throw, so a result is always checked, never caught.

    ```luau
    const mrow = require("./src")

    const point = mrow.between(
        mrow.token(mrow.string("(")),
        mrow.map(mrow.separated(mrow.token(mrow.integer), mrow.token(mrow.string(","))), function(values: { number })
            return { x = values[1], y = values[2] }
        end),
        mrow.token(mrow.string(")"))
    )

    const parsed = mrow.parse("(1, 2)", point)
    if parsed.failed then
        print(parsed.error:format())
    else
        const value = parsed:unwrap()
        print(value.x, value.y) --> 1 2
    end
    ```
]=]
const mrow = {}

const parser = require("@self/parser")
const result = require("@self/result")

mrow.parser = parser
mrow.result = result

mrow.string = require("@self/parser_atomic/string")
mrow.satisfy = require("@self/parser_atomic/satisfy")
mrow.any = require("@self/parser_atomic/any")
mrow.one_of = require("@self/parser_atomic/one_of")
mrow.none_of = require("@self/parser_atomic/none_of")
mrow.spaces = require("@self/parser_atomic/spaces")
mrow.eof = require("@self/parser_atomic/eof")

mrow.natural = require("@self/parser_primitive/natural_number")
mrow.integer = require("@self/parser_primitive/integer")

mrow.choice = require("@self/parser_combinate/choice")
mrow.sequence = require("@self/parser_combinate/sequence")
mrow.many = require("@self/parser_combinate/many")
mrow.some = require("@self/parser_combinate/some")
mrow.optional = require("@self/parser_combinate/optional")
mrow.map = require("@self/parser_combinate/map")
mrow.between = require("@self/parser_combinate/between")
mrow.separated = require("@self/parser_combinate/separated")
mrow.token = require("@self/parser_combinate/token")
mrow.lazy = require("@self/parser_combinate/lazy")
mrow.label = require("@self/parser_combinate/label")

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
