const parser_data = require("./parser_data")
const parser_result = require("./parser_result")

const parser_stream = {}

function parser_stream.peek(data: parser_data.ParserData): parser_result.ParserResult<string>
    if data.char_index > data.chars_length then
        return parser_result.fail(data, "unexpected end of input")
    end

    return parser_result.success(data.chars[data.char_index])
end

function parser_stream.consume(data: parser_data.ParserData): parser_result.ParserResult<string>
    const char_result = parser_stream.peek(data)
    if char_result.failed then
        return char_result
    end

    const char = char_result:unwrap()

    if char == "\n" then
        data.position.column = 0
        data.position.line += 1
    end

    data.position.column += 1
    data.char_index += 1

    return parser_result.success(char)
end

return parser_stream
