const parser = require("../parser")
const result = require("../result")

return function(description: string, predicate: (string) -> boolean): parser.Parser<string>
    return function(data: parser.ParserData): parser.ParserResult<string>
        const char_result = parser.peek(data)
        if char_result.failed then
            return parser.fail(data, `expected {description}, got end of input`)
        end

        const char = char_result:unwrap()
        if not predicate(char) then
            return parser.fail(data, `expected {description}, got '{char}'`)
        end

        parser.consume(data)

        return result.success(char)
    end
end
