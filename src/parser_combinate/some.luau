const parser = require("../parser")
const result = require("../result")
const many = require("./many")

--[=[
    @tag combinator
    @param item Parser<T>
    @return Parser<{ T }>

    Like [mrow.many], but demands at least one match: with none, it fails with the
    error `item` gave and consumes nothing.

    ```luau
    const digits = mrow.some(mrow.one_of("0123456789"))
    #mrow.parse("42", digits):unwrap() --> 2
    mrow.parse("", digits).failed --> true
    ```
]=]
return function<T>(item: parser.Parser<T>): parser.Parser<{ T }>
    const rest = many(item)

    return function(data: parser.ParserData): parser.ParserResult<{ T }>
        const state = parser.save(data)

        const first = item(data)
        if first.failed then
            return first
        end

        const others = rest(data)
        if others.failed then
            parser.restore(data, state)

            return others
        end

        const values = { first:unwrap() }
        for _, value in others:unwrap() do
            table.insert(values, value)
        end

        return result.success(values)
    end
end
