const parser = require("../parser")
const spaces = require("../parser_atomic/spaces")

--[=[
    @tag combinator
    @param target Parser<T...>
    @return Parser<T...>

    Runs `target` and then eats the whitespace behind it, so the next parser always
    starts on meaningful input. Leading whitespace is nobody's token — eat it once, at
    the very start of the grammar, and let every token clean up after itself.

    ```lua
    const number = mrow.token(mrow.integer)
    const list = mrow.separated(number, mrow.token(mrow.string(",")))

    mrow.parse("1, 2, 3", list):unwrap() --> { 1, 2, 3 }
    ```
]=]
return function<T...>(target: parser.Parser<T...>): parser.Parser<T...>
    return function(data: parser.ParserData): parser.ParserResult<T...>
        const parsed = target(data)
        if parsed.failed then
            return parsed
        end

        spaces(data)

        return parsed
    end
end
