const parser = require("../parser")

--[=[
    @tag atomic
    @param expected string -- The exact text to match
    @return ParserFrame

    Builds a parser that matches `expected` literally and returns it. Nothing is
    consumed unless the whole text matches, so the next alternative in a [mrow.choice]
    still sees the whole text.

    ```luau
    const let = mrow.string("let")
    mrow.create(let)("let").value --> "let"
    mrow.create(let)("les").error --> "expected 'let', but got 'les'" -- and nothing was consumed
    ```
]=]
return function(expected: string): parser.ParserFrame
    -- Compare byte by byte, so a failed match does not build a substring to compare.
    const expected_bytes = { string.byte(expected, 1, -1) }
    const expected_length = #expected_bytes

    return function(context: parser.ParserContext)
        const source = context.source
        const start_offset = context.offset

        for i = 1, expected_length do
            const offset = start_offset + i - 1
            const byte = string.byte(source, offset)

            if not byte then
                context.return_error = `expected '{expected}', but got end of input`
                return
            end

            if byte ~= expected_bytes[i] then
                -- Show the input up to the end of the character that differs, which
                -- may start before `offset` when only a later byte of it differs.
                -- `source` is valid UTF-8, so both lookups always find a character.
                const char_start = utf8.offset(source, 0, offset) :: number
                const next_char = utf8.offset(source, 2, char_start) :: number

                context.return_error =
                    `expected '{expected}', but got '{string.sub(source, start_offset, next_char - 1)}'`
                return
            end
        end

        context.offset = start_offset + expected_length
        context.return_value = expected
    end
end
