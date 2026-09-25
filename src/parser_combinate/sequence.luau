const parser = require("../parser")
const result = require("../result")

--[=[
    @tag combinator
    @param ... Parser<...any> -- Run one after another
    @return Parser<never> -- Succeeds with no value at all

    Runs every parser in order and throws their values away; use it to match a shape
    you only need to check. As soon as one of them fails the whole sequence fails and
    rewinds to where it started. To keep a value out of the middle, reach for
    [mrow.between] or give the pieces to [mrow.map] yourself.

    ```lua
    const assignment = mrow.sequence(mrow.string("a"), mrow.string("="), mrow.natural)
    mrow.parse("a=1", assignment).failed --> false
    mrow.parse("a=x", assignment).failed --> true -- and nothing was consumed
    ```
]=]
const function sequence(...: parser.Parser<...any>): parser.Parser<never>
    const parsers = { ... }
    const parser_count = #parsers

    return function(data: parser.ParserData): parser.ParserResult<...any>
        const state = parser.save(data)

        for i = 1, parser_count do
            const parsed = parsers[i](data)
            if parsed.failed then
                parser.restore(data, state)

                return parsed
            end
        end

        return result.success()
    end
end

return sequence
