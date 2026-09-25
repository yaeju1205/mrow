const parser = require("../parser")
const spaces = require("../parser_atomic/spaces")

return function<T...>(target: parser.Parser<T...>): parser.Parser<T...>
    return function(data: parser.ParserData): parser.ParserResult<T...>
        const parsed = target(data)
        if parsed.failed then
            return parsed
        end

        spaces(data)

        return parsed
    end
end
