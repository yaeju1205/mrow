const parser = require("../parser")

return function<T...>(make: () -> parser.Parser<T...>): parser.Parser<T...>
    local made: parser.Parser<T...>? = nil

    return function(data: parser.ParserData): parser.ParserResult<T...>
        const target: parser.Parser<T...> = made or make()
        made = target

        return target(data)
    end
end
