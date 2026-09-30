const parser = require("../parser")

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
    const position = data.position
    const start = data.char_index
    local index = start

    while index <= data.chars_length do
        const char = chars[index]
        if WHITESPACE[char] == nil then
            break
        end

        if char == "\n" then
            position.line += 1
            position.column = 1
        else
            position.column += 1
        end

        index += 1
    end

    data.char_index = index

    return parser.success(table.concat(chars, "", start, index - 1))
end
