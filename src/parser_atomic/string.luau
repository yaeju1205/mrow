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
    -- Split once here, so a match compares codepoints instead of re-slicing
    -- `expected` for every character it reads.
    const expected_chars: { string } = {}
    local newlines = 0

    if utf8.len(expected) then
        for _, code in utf8.codes(expected) do
            const char = utf8.char(code)
            table.insert(expected_chars, char)

            if char == "\n" then
                newlines += 1
            end
        end
    end

    const expected_length = #expected_chars
    const matched = if expected_length == 0 then "" else expected

    return function(data: parser.ParserData): parser.ParserResult<string>
        const chars = data.chars
        const start = data.position

        for i = 1, expected_length do
            const position = start + i - 1
            if position > data.length then
                return parser.fail(data, `expected '{expected}', got end of input`)
            end

            if chars[position] ~= expected_chars[i] then
                return parser.fail(data, `expected '{expected}', got '{table.concat(chars, "", start, position)}'`)
            end
        end

        data.position = start + expected_length
        data.line += newlines

        return result.success(matched)
    end
end
