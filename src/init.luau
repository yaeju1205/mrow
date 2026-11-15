const mrow = {}

const parser = require("@self/parser")

mrow.parser = parser
mrow.create = parser.create

mrow.string = require("@self/parser_frame_atomic/string")
mrow.satisfy = require("@self/parser_frame_atomic/satisfy")
mrow.any = require("@self/parser_frame_atomic/any")
mrow.one_of = require("@self/parser_frame_atomic/one_of")
mrow.none_of = require("@self/parser_frame_atomic/none_of")
mrow.spaces = require("@self/parser_frame_atomic/spaces")
mrow.eof = require("@self/parser_frame_atomic/eof")

mrow.unsigned_integer = require("@self/parser_frame_primitive/unsigned_integer")
mrow.integer = require("@self/parser_frame_primitive/integer")

mrow.choice = require("@self/parser_frame_combinator/choice")
mrow.sequence = require("@self/parser_frame_combinator/sequence")
mrow.many = require("@self/parser_frame_combinator/many")
mrow.some = require("@self/parser_frame_combinator/some")
mrow.optional = require("@self/parser_frame_combinator/optional")
mrow.map = require("@self/parser_frame_combinator/map")
mrow.between = require("@self/parser_frame_combinator/between")
mrow.separated = require("@self/parser_frame_combinator/separated")
mrow.token = require("@self/parser_frame_combinator/token")
mrow.lazy = require("@self/parser_frame_combinator/lazy")
mrow.label = require("@self/parser_frame_combinator/label")

export type ParserFrame = parser.ParserFrame
export type ParserContext = parser.ParserContext
export type ParserFailed = parser.ParserFailed
export type ParserSuccess<T> = parser.ParserSuccess<T>
export type Parser<T> = parser.Parser<T>

return mrow
