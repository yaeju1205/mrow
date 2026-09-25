const parser = require("../parser")
const result = require("../result")

return function<T>(item: parser.Parser<T>): parser.Parser<{ T }>
    return function(data: parser.ParserData): parser.ParserResult<{ T }>
        const values: { T } = {}

        while true do
            const before = data.position

            const parsed = item(data)
            if parsed.failed then
                break
            end

            table.insert(values, parsed:unwrap())

            if data.position == before then
                break
            end
        end

        return result.success(values)
    end
end
