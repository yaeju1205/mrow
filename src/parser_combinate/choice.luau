const parser = require("../parser")
const result = require("../result")

return function<T...>(...: parser.Parser<T...>): parser.Parser<T...>
    const parsers = { ... }
    const parser_count = #parsers

    return function(data: parser.ParserData): parser.ParserResult<T...>
        const state = parser.save(data)
        const errors: { parser.ParserError } = {}

        for i=1, parser_count do
            const parsed_result = parsers[i](data)

            if not parsed_result.failed then
                return parsed_result
            end

            const failed = parsed_result.error.errors
            for j=1, #failed do
                table.insert(errors, failed[j])
            end

            parser.restore(data, state)
        end

        return result.failed(parser.errors(errors))
    end
end
