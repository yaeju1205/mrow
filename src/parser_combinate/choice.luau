const parser = require("../parser")

--[=[
    @tag combinator
    @param ... Parser<T...> -- The alternatives, tried from left to right
    @return Parser<T...>

    Returns the result of the first alternative that succeeds. The position is restored
    before each attempt, so alternatives are free to share a prefix. When they all fail,
    every one of their errors is collected into the returned [ParserFailed], so the
    message lists each thing that could have been there — wrap it in [mrow.label] to
    report one expectation instead.

    ```luau
    const boolean = mrow.choice(mrow.string("true"), mrow.string("false"))
    mrow.parse("false", boolean):unwrap() --> "false"
    mrow.parse("maybe", boolean).failed --> true
    ```
]=]
return function<T...>(...: parser.Parser<T...>): parser.Parser<T...>
    const parsers = { ... }
    const parser_count = #parsers

    return function(data: parser.ParserData): parser.ParserResult<T...>
        const state = parser.store(data)
        const errors: { parser.ParserError } = {}

        for i=1, parser_count do
            const parsed_result = parsers[i](data)

            if not parsed_result.failed then
                return parsed_result
            end

            const failed = parsed_result.errors
            for j=1, #failed do
                table.insert(errors, failed[j])
            end

            parser.restore(data, state)
        end

        return {
            failed = true,
            errors = errors,
            format = parser.format,
        }
    end
end
