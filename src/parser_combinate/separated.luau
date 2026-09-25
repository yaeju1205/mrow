const parser = require("../parser")
const result = require("../result")

return function<T, S>(item: parser.Parser<T>, separator: parser.Parser<S>): parser.Parser<{ T }>
    return function(data: parser.ParserData): parser.ParserResult<{ T }>
        const values: { T } = {}

        const first = item(data)
        if first.failed then
            return result.success(values)
        end

        table.insert(values, first:unwrap())

        while true do
            const state = parser.save(data)

            const separated = separator(data)
            if separated.failed then
                break
            end

            const next_item = item(data)
            if next_item.failed then
                parser.restore(data, state)

                break
            end

            table.insert(values, next_item:unwrap())
        end

        return result.success(values)
    end
end
