const parser = require("../parser")

--[=[
    @tag atomic
    @param context ParserContext

    Succeeds with `nil` when nothing is left to read, and consumes nothing.
    [mrow.create] stops wherever the root parser stops and never looks at the rest of
    the input, so end a grammar with this when it has to read the whole source.

    ```luau
    const whole_line = mrow.sequence(mrow.some(mrow.none_of("\n")), mrow.eof)
    mrow.create(whole_line)("abc").success --> true
    mrow.create(whole_line)("abc\n").success --> false
    ```
]=]
return function(context: parser.ParserContext)
    const char = parser.peek(context)

    if char then
        context.return_error = `expected end of input, but got '{char}'`
        return
    end

    context.return_value = nil
end
