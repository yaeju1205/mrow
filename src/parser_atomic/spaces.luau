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

    ```luau
    mrow.parse("  \n", mrow.spaces):unwrap() --> "  \n"
    mrow.parse_partial("a", mrow.spaces):unwrap() --> ""
    ```
]=]
return function(data: parser.ParserData): parser.ParserResult<string>
    const chars = data.chars
    const start = data.position
    local position = start

    while position <= data.length do
        const char = chars[position]
        if WHITESPACE[char] == nil then
            break
        end

        if char == "\n" then
            data.line += 1
        end

        position += 1
    end

    data.position = position

    return result.success(table.concat(chars, "", start, position - 1))
end
