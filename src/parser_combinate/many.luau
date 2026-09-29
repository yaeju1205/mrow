const parser = require("../parser")
const result = require("../result")

--[=[
    @tag combinator
    @param item Parser<T>
    @return Parser<{ T }>

    Runs `item` over and over until it fails, and collects every value it produced.
    Never fails: zero matches is a success holding an empty table — use [mrow.some]
    to demand at least one. An `item` that succeeds without moving the position ends
    the loop instead of spinning forever.

    ```luau
    const digits = mrow.many(mrow.one_of("0123456789"))
    #mrow.parse("123", digits):unwrap() --> 3
    #mrow.parse("", digits):unwrap() --> 0
    ```
]=]
return function<T>(item: parser.Parser<T>): parser.Parser<{ T }>
    return function(data: parser.ParserData): parser.ParserResult<{ T }>
        const values: { T } = {}

        while true do
            const before = data.position

            const parsed = item(data)
            if parsed.failed then
                break
            end

            table.insert(values, (parsed:unwrap()))

            if data.position == before then
                break
            end
        end

        return result.success(values)
    end
end
