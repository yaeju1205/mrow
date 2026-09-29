const parser = require("../parser")
const result = require("../result")

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
    const start = data.position
    local position = start

    while position <= data.length do
        const char = chars[position]
        if char < "0" or char > "9" then
            break
        end

        position += 1
    end

    const number = tonumber(table.concat(chars, "", start, position - 1))
    if not number then
        return parser.fail(data, `expected natural number, got end of input`)
    end

    data.position = position

    return result.success(number)
end
