const parser = require("../parser")
const result = require("../result")

return function(data: parser.ParserData): parser.ParserResult<()>
    const char_result = parser.peek(data)
    if char_result.failed then
        return result.success()
    end

    return parser.fail(data, `expected end of input, got '{char_result:unwrap()}'`)
end
