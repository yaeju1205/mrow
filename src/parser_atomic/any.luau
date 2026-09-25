const parser = require("../parser")

return function(data: parser.ParserData): parser.ParserResult<string>
    const char_result = parser.consume(data)
    if char_result.failed then
        return parser.fail(data, "expected any character, got end of input")
    end

    return char_result
end
