const parser = require("../parser")

--[=[
    @tag atomic
    @param context ParserContext

    Consumes the next character, whatever it is, and returns it.
    Fails when the input is already exhausted.

    ```luau
    mrow.create(mrow.any)("a").value --> "a"
    mrow.create(mrow.any)("").success --> false
    ```
]=]
return function(context: parser.ParserContext)
    const char = parser.next(context)

    if not char then
        context.return_error = "expected any character, but got end of input"
        return
    end

    context.return_value = char
end
