const parser = require("../parser")

--[=[
    @tag primitive
    @param data ParserData
    @return ParserResult<number>

    Reads one or more decimal digits and returns them as a number. A sign is not part
    of the syntax here, use [mrow.integer] for that.

    ```luau
    mrow.parse("0042", mrow.natural):unwrap() --> 42
    mrow.parse("-1", mrow.natural).failed --> true
    ```
]=]
return function(data: parser.ParserData): parser.ParserResult<number>
    const chars = data.chars
    const start = data.char_index
    local index = start

    while index <= data.chars_length do
        const char = chars[index]
        if char < "0" or char > "9" then
            break
        end

        index += 1
    end

    const number = tonumber(table.concat(chars, "", start, index - 1))
    if not number then
        if start > data.chars_length then
            return parser.fail(data, `expected natural number, got end of input`)
        end

        return parser.fail(data, `expected natural number, got '{chars[start]}'`)
    end

    data.char_index = index
    data.position.column += index - start

    return parser.success(number)
end
