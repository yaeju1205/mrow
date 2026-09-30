const parser = require("../parser")
const trampoline = require("../trampoline")

const step = trampoline.step

--[=[
    @tag combinator
    @param target Parser<T...>
    @param transform (T...) -> U -- Receives every value `target` produced
    @return Parser<U>

    Runs `target` and hands its values to `transform`, so a parser can produce a value
    of your own shape instead of the raw characters it matched.

    ```luau
    const word = mrow.map(mrow.some(mrow.one_of("abc")), function(chars: { string }): string
        return table.concat(chars)
    end)

    mrow.parse("cab", word):unwrap() --> "cab"
    ```
]=]
return function<U, T...>(target: parser.Parser<T...>, transform: (T...) -> U): parser.Parser<U>
    if trampoline.is_leaves(target) then
        return trampoline.leaf(function(data: parser.ParserData): parser.ParserResult<U>
            const parsed = target(data)
            if parsed.failed then
                return parsed
            end

            return parser.success(transform(parsed:unwrap()))
        end)
    end

    const function continue(parsed: any): ...any
        if parsed.failed then
            return parsed
        end

        return parser.success(transform(parsed:unwrap()))
    end

    return function(data: parser.ParserData): ...any
        return step(target, data, continue)
    end
end
