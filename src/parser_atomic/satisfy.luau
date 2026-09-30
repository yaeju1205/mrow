const parser = require("../parser")
const trampoline = require("../trampoline")

--[=[
    @tag atomic
    @param description string -- Named in the error as `expected {description}, got ...`
    @param predicate (string) -> boolean -- Tested against the next character
    @return Parser<string>

    Builds a parser that consumes the next character when `predicate` accepts it.
    Every other atomic parser is built on top of this one; reach for it when a
    character class is easier to write as code than as a list of characters.

    ```luau
    const upper = mrow.satisfy("uppercase letter", function(char: string): boolean
        return char:lower() ~= char
    end)

    mrow.parse("A", upper):unwrap() --> "A"
    mrow.parse("a", upper):format() --> ... expected uppercase letter, got 'a'
    ```
]=]
return function(description: string, predicate: (string) -> boolean): parser.Parser<string>
    return trampoline.leaf(function(data: parser.ParserData): parser.ParserResult<string>
        const index = data.char_index
        if index > data.chars_length then
            return parser.fail(data, `expected {description}, got end of input`)
        end

        const char = data.chars[index]
        if not predicate(char) then
            return parser.fail(data, `expected {description}, got '{char}'`)
        end

        if char == "\n" then
            data.position.line += 1
            data.position.column = 1
        else
            data.position.column += 1
        end

        data.char_index = index + 1

        return parser.success(char)
    end)
end
