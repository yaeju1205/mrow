const parser = require("../parser")

return function<T>(make_frame: () -> parser.ParserFrame): parser.ParserFrame
    local frame: parser.ParserFrame = nil

    return function(context: parser.ParserContext)
        frame = frame or make_frame()

        frame(context)
    end
end
