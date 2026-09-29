const parser = require("../parser")
const result = require("../result")
const natural_number = require("./natural_number")

--[=[
    @tag primitive
    @param data ParserData
    @return ParserResult<number>

    Reads a decimal number with an optional leading `+` or `-`. A lone sign with no
    digits after it fails and consumes nothing.

    ```luau
    mrow.parse("-42", mrow.integer):unwrap() --> -42
    mrow.parse("+7", mrow.integer):unwrap() --> 7
    mrow.parse("-", mrow.integer).failed --> true
    ```
]=]
return function(data: parser.ParserData): parser.ParserResult<number>
    const state = parser.save(data)

    local sign = 1

    const first = parser.peek(data)
    if not first.failed then
        const char = first:unwrap()

        if char == "-" then
            sign = -1
            data.position += 1
        elseif char == "+" then
            data.position += 1
        end
    end

    const digits = natural_number(data)
    if digits.failed then
        parser.restore(data, state)

        return digits
    end

    return result.success(sign * digits:unwrap())
end
