const parser = require("../parser")
const result = require("../result")

--[=[
    @tag atomic
    @param expected string -- The exact text to match
    @return Parser<string>

    Builds a parser that matches `expected` literally and returns it. The position is
    restored when the match breaks halfway, so a failure consumes nothing and the next
    alternative in a [mrow.choice] still sees the whole text.

    ```luau
    const let = mrow.string("let")
    mrow.parse("let", let):unwrap() --> "let"
    mrow.parse("les", let).failed --> true -- and nothing was consumed
    ```
]=]
return function(expected: string): parser.Parser<string>
    const expected_length = utf8.len(expected) or 0

    return function(data: parser.ParserData): parser.ParserResult<string>
        const state = parser.save(data)
        local got = ""

        for i=1, expected_length do
            const char_result = parser.consume(data)
            if char_result.failed then
                parser.restore(data, state)

                return parser.fail(data, `expected '{expected}', got end of input`)
            end

            got ..= char_result:unwrap()

            if string.sub(expected, 1, #got) ~= got then
                parser.restore(data, state)

                return parser.fail(data, `expected '{expected}', got '{got}'`)
            end
        end

        return result.success(got)
    end
end
