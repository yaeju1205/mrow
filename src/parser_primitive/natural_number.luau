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
    const state = parser.save(data)
    local parsed_data = ""

    while true do
        const char_result = parser.peek(data)
        if char_result.failed then
            break
        end

        const char = char_result:unwrap()

        if char < "0" or char > "9" then
            break
        end

        parser.consume(data)
        parsed_data ..= char
    end

    const number = tonumber(parsed_data)
    if not number then
        parser.restore(data, state)

        return parser.fail(data, `expected natural number, got end of input`)
    end

    return result.success(number)
end
