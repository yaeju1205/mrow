const parser = require("../parser")
const result = require("../result")

const WHITESPACE: { [string]: true } = {
    [" "] = true,
    ["\t"] = true,
    ["\n"] = true,
    ["\r"] = true,
}

return function(data: parser.ParserData): parser.ParserResult<string>
    local eaten = ""

    while true do
        const char_result = parser.peek(data)
        if char_result.failed then
            break
        end

        const char = char_result:unwrap()
        if WHITESPACE[char] == nil then
            break
        end

        parser.consume(data)
        eaten ..= char
    end

    return result.success(eaten)
end
