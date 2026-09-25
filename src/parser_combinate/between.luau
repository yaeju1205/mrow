const parser = require("../parser")
const result = require("../result")

return function<O, T, C>(open: parser.Parser<O>, inner: parser.Parser<T>, close: parser.Parser<C>): parser.Parser<T>
    return function(data: parser.ParserData): parser.ParserResult<T>
        const state = parser.save(data)

        const opened = open(data)
        if opened.failed then
            return opened
        end

        const value = inner(data)
        if value.failed then
            parser.restore(data, state)

            return value
        end

        const closed = close(data)
        if closed.failed then
            parser.restore(data, state)

            return closed
        end

        return result.success(value:unwrap())
    end
end
