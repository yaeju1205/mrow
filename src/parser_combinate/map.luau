const parser = require("../parser")
const result = require("../result")

return function<U, T...>(target: parser.Parser<T...>, transform: (T...) -> U): parser.Parser<U>
    return function(data: parser.ParserData): parser.ParserResult<U>
        const parsed = target(data)
        if parsed.failed then
            return parsed
        end

        return result.success(transform(parsed:unwrap()))
    end
end
