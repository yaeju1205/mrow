const parser = require("../parser")
const result = require("../result")

const WHITESPACE: { [string]: true } = {
    [" "] = true,
    ["\t"] = true,
    ["\n"] = true,
    ["\r"] = true,
}

--[=[
    @tag atomic
    @param data ParserData
    @return ParserResult<string>

    Consumes whitespace (space, `\t`, `\n`, `\r`) until something else shows up,
    and returns the text it ate. Never fails: eating nothing is a success with `""`.

    ```lua
    mrow.parse("  \n", mrow.spaces):unwrap() --> "  \n"
    mrow.parse_partial("a", mrow.spaces):unwrap() --> ""
    ```
]=]
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
