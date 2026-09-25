const parser = require("../parser")
const result = require("../result")

--[=[
    @tag atomic
    @param data ParserData
    @return ParserResult<()>

    Succeeds with no value when nothing is left to read, and consumes nothing.
    [mrow.parse] already runs it after the target parser, so it is only needed
    inside a grammar that has to assert the end of input by itself.

    ```luau
    const whole_line = mrow.sequence(mrow.some(mrow.none_of("\n")), mrow.eof)
    mrow.parse_partial("abc", whole_line).failed --> false
    mrow.parse_partial("abc\n", whole_line).failed --> true
    ```
]=]
return function(data: parser.ParserData): parser.ParserResult<()>
    const char_result = parser.peek(data)
    if char_result.failed then
        return result.success()
    end

    return parser.fail(data, `expected end of input, got '{char_result:unwrap()}'`)
end
