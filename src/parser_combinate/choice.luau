const parser = require("../parser")
const trampoline = require("../trampoline")

const CALL = trampoline.CALL
const step = trampoline.step

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

    if trampoline.is_leaves(...) then
        return trampoline.leaf(function(data: parser.ParserData): parser.ParserResult<T...>
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
        end)
    end

    const leaf_at: { boolean } = {}
    for i = 1, parser_count do
        leaf_at[i] = trampoline.is_leaves(parsers[i])
    end

    const function fail_all(errors: { parser.ParserError }): parser.ParserFailed
        return {
            failed = true,
            errors = errors,
            format = parser.format,
        }
    end

    -- From the first alternative that is not a leaf on, the rest are tried through
    -- the trampoline, coming back to `continue` after each one
    const function suspend(
        data: parser.ParserData,
        state: parser.ParserPosition,
        errors: { parser.ParserError },
        from: number
    ): ...any
        local i = from

        local function continue(parsed: any): ...any
            if not parsed.failed then
                return parsed
            end

            const failed = parsed.errors
            for j = 1, #failed do
                table.insert(errors, failed[j])
            end

            parser.restore(data, state)

            i += 1
            if i > parser_count then
                return fail_all(errors)
            end

            return step(parsers[i], data, continue)
        end

        return CALL, parsers[i], continue
    end

    return function(data: parser.ParserData): ...any
        const state = parser.store(data)
        const errors: { parser.ParserError } = {}

        for i = 1, parser_count do
            if not leaf_at[i] then
                return suspend(data, state, errors, i)
            end

            const parsed = parsers[i](data)
            if not parsed.failed then
                return parsed
            end

            const failed = parsed.errors
            for j = 1, #failed do
                table.insert(errors, failed[j])
            end

            parser.restore(data, state)
        end

        return fail_all(errors)
    end
end
