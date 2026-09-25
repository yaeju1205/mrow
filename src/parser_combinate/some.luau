const parser = require("../parser")
const result = require("../result")
const many = require("./many")

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
