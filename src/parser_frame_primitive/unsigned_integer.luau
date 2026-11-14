const parser = require("../parser")

return function(context: parser.ParserContext)
    const start_offset = context.offset
    local offset = start_offset

    while true do
        const char = context.chars[offset]

        if not char or char < "0" or char > "9" then
            break
        end

        offset += 1
    end

    if start_offset == offset then
        context.return_error = `expected unsigned int, but got '{parser.peek(context)}'`
        return
    end

    const uint_str = table.concat(context.chars, "", start_offset, offset - 1)
    const uint = tonumber(uint_str)

    if not uint then
        context.return_error = `expected unsigned int, but got '{uint_str}'`
        return
    end

    context.offset = offset
    context.column += start_offset - offset
    context.return_value = uint
end
