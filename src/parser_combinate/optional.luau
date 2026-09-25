const parser = require("../parser")
const result = require("../result")

return function<T>(item: parser.Parser<T>): parser.Parser<T?>
    return function(data: parser.ParserData): parser.ParserResult<T?>
        const parsed = item(data)
        if parsed.failed then
            return result.success(nil)
        end

        return result.success(parsed:unwrap())
    end
end
