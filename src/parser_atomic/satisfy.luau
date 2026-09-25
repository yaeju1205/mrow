const parser = require("../parser")
const result = require("../result")

--[=[
    @tag atomic
    @param description string -- Named in the error as `expected {description}, got ...`
    @param predicate (string) -> boolean -- Tested against the next character
    @return Parser<string>

    Builds a parser that consumes the next character when `predicate` accepts it.
    Every other atomic parser is built on top of this one; reach for it when a
    character class is easier to write as code than as a list of characters.

    ```lua
    const upper = mrow.satisfy("uppercase letter", function(char: string): boolean
        return char:lower() ~= char
    end)

    mrow.parse("A", upper):unwrap() --> "A"
    mrow.parse("a", upper).error:format() --> ... expected uppercase letter, got 'a'
    ```
]=]
return function(description: string, predicate: (string) -> boolean): parser.Parser<string>
    return function(data: parser.ParserData): parser.ParserResult<string>
        const char_result = parser.peek(data)
        if char_result.failed then
            return parser.fail(data, `expected {description}, got end of input`)
        end

        const char = char_result:unwrap()
        if not predicate(char) then
            return parser.fail(data, `expected {description}, got '{char}'`)
        end

        parser.consume(data)

        return result.success(char)
    end
end
