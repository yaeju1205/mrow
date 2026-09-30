const parser = require("../parser")

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
    local last_line_length = 0

    if utf8.len(expected) then
        for _, code in utf8.codes(expected) do
            const char = utf8.char(code)
            table.insert(expected_chars, char)

            if char == "\n" then
                newlines += 1
                last_line_length = 0
            else
                last_line_length += 1
            end
        end
    end

    const expected_length = #expected_chars
    const matched = if expected_length == 0 then "" else expected

    return function(data: parser.ParserData): parser.ParserResult<string>
        const chars = data.chars
        const start = data.char_index

        for i = 1, expected_length do
            const index = start + i - 1
            if index > data.chars_length then
                return parser.fail(data, `expected '{expected}', got end of input`)
            end

            if chars[index] ~= expected_chars[i] then
                return parser.fail(data, `expected '{expected}', got '{table.concat(chars, "", start, index)}'`)
            end
        end

        data.char_index = start + expected_length

        const position = data.position
        if newlines == 0 then
            position.column += expected_length
        else
            position.line += newlines
            position.column = last_line_length + 1
        end

        return parser.success(matched)
    end
end
