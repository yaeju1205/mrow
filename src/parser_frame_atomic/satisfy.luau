const parser = require("../parser")

--[=[
    @tag atomic
    @param description string -- Named in the error as `expected {description}, but got ...`
    @param predicate (string) -> boolean -- Tested against the next character
    @return ParserFrame

    Builds a parser that consumes the next character when `predicate` accepts it.
    [mrow.one_of] and [mrow.none_of] are built on top of this one; reach for it when a
    character class is easier to write as code than as a list of characters.

    ```luau
    const upper = mrow.satisfy("uppercase letter", function(char: string): boolean
        return char:lower() ~= char
    end)

    mrow.create(upper)("A").value --> "A"
    mrow.create(upper)("a").error --> "expected uppercase letter, but got 'a'"
    ```
]=]
return function(description: string, predicate: (string) -> boolean): parser.ParserFrame
    return function(context: parser.ParserContext)
        const char = parser.peek(context)

        if not char then
            context.return_error = `expected {description}, but got end of input`
            return
        end

        if not predicate(char) then
            context.return_error = `expected {description}, but got '{char}'`
            return
        end

        context.offset += #char
        context.return_value = char
    end
end
