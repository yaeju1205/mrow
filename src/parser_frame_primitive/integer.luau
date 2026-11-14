const parser = require("../parser")
const unsigned_integer = require("./unsigned_integer")

return function(context: parser.ParserContext)
    local sign = 1

    const sign_char = parser.peek(context)
    if sign_char == "-" or sign_char == "+" then
        if sign_char == "-" then
            sign = -1
        end

        context.offset += 1
        context.column += 1
    end

    parser.stack_frame_push(context, function(context)
        if context.return_error then
            return
        end

        local uint = context.return_value
        context.return_value = sign * uint
    end)

    parser.stack_frame_push(context, unsigned_integer)
end
