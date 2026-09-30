const parser = require("../parser")
const trampoline = require("../trampoline")

--[=[
    @tag atomic
    @param data ParserData
    @return ParserResult<string>

    Consumes the next character, whatever it is, and returns it.
    Fails when the input is already exhausted.

    ```luau
    mrow.parse("a", mrow.any):unwrap() --> "a"
    mrow.parse("", mrow.any).failed --> true
    ```
]=]
return trampoline.leaf(function(data: parser.ParserData): parser.ParserResult<string>
    const char_result = parser.consume(data)
    if char_result.failed then
        return parser.fail(data, "expected any character, got end of input")
    end

    return char_result
end)
