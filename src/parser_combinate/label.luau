const parser = require("../parser")

--[=[
    @tag combinator
    @param description string -- Reported as `expected {description}`
    @param target Parser<T...>
    @return Parser<T...>

    Replaces everything `target` failed with by a single `expected {description}` error
    pointing at where `target` started, so a deep grammar reports one readable
    expectation instead of every internal attempt it made.

    ```lua
    const identifier = mrow.label("identifier", mrow.some(mrow.one_of("abcdefghijklmnopqrstuvwxyz")))
    mrow.parse("1", identifier).error:format() --> ... expected identifier
    ```
]=]
return function<T...>(description: string, target: parser.Parser<T...>): parser.Parser<T...>
    return function(data: parser.ParserData): parser.ParserResult<T...>
        const state = parser.save(data)

        const parsed = target(data)
        if not parsed.failed then
            return parsed
        end

        parser.restore(data, state)

        return parser.fail(data, `expected {description}`)
    end
end
