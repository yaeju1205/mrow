const parser = require("../parser")
const trampoline = require("../trampoline")

const step = trampoline.step

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
    if trampoline.is_leaves(item, separator) then
        return trampoline.leaf(function(data: parser.ParserData): parser.ParserResult<{ T }>
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
        end)
    end

    return function(data: parser.ParserData): ...any
        const values: { T } = {}
        local state = parser.store(data)
        local before = data.char_index
        local count = 0

        local after_item: (any) -> ...any

        const function after_separator(separated: any): ...any
            if separated.failed then
                return parser.success(values)
            end

            return step(item, data, after_item)
        end

        after_item = function(next_item: any): ...any
            if next_item.failed then
                if count > 0 then
                    parser.restore(data, state)
                end

                return parser.success(values)
            end

            table.insert(values, (next_item:unwrap()))
            count += 1

            if count > 1 and data.char_index == before then
                return parser.success(values)
            end

            state = parser.store(data)
            before = data.char_index

            return step(separator, data, after_separator)
        end

        return step(item, data, after_item)
    end
end
