const parser = require("../parser")

--[=[
    @tag combinator
    @param item Parser<T>
    @param separator Parser<S> -- Matched between items, its value is dropped
    @return Parser<{ T }>

    Parses `item` repeatedly, with `separator` in between, and collects the items.
    Never fails: an empty list is a success holding an empty table. A separator with
    no item behind it is left unconsumed, so a trailing comma stays for the parser
    that comes next to complain about.

    ```luau
    const list = mrow.separated(mrow.integer, mrow.string(","))
    mrow.parse("1,2,3", list):unwrap() --> { 1, 2, 3 }
    mrow.parse("", list):unwrap() --> {}
    ```
]=]
return function<T, S>(item: parser.Parser<T>, separator: parser.Parser<S>): parser.Parser<{ T }>
    return function(data: parser.ParserData): parser.ParserResult<{ T }>
        const values: { T } = {}

        const first = item(data)
        if first.failed then
            return parser.success(values)
        end

        table.insert(values, (first:unwrap()))

        while true do
            const state = parser.store(data)
            const before = data.char_index

            const separated = separator(data)
            if separated.failed then
                break
            end

            const next_item = item(data)
            if next_item.failed then
                parser.restore(data, state)

                break
            end

            table.insert(values, (next_item:unwrap()))

            if data.char_index == before then
                break
            end
        end

        return parser.success(values)
    end
end
