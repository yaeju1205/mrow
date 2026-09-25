const parser = require("../parser")

return function<T...>(description: string, target: parser.Parser<T...>): parser.Parser<T...>
    return function(data: parser.ParserData): parser.ParserResult<T...>
        const state = parser.save(data)

        const parsed = target(data)
        if not parsed.failed then
            return parsed
        end

        parser.restore(data, state)

        return parser.fail(data, `expected {description}`)
    end
end
