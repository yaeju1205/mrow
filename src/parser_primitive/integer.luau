const parser = require("../parser")
const result = require("../result")
const natural_number = require("./natural_number")

return function(data: parser.ParserData): parser.ParserResult<number>
    const state = parser.save(data)

    local sign = 1

    const first = parser.peek(data)
    if not first.failed then
        const char = first:unwrap()

        if char == "-" then
            sign = -1
            parser.consume(data)
        elseif char == "+" then
            parser.consume(data)
        end
    end

    const digits = natural_number(data)
    if digits.failed then
        parser.restore(data, state)

        return digits
    end

    return result.success(sign * digits:unwrap())
end
