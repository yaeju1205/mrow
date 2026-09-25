const parser = require("../parser")
const result = require("../result")

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
