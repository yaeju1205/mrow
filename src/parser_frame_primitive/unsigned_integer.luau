const parser = require("../parser")

--[=[
    @tag primitive
    @param context ParserContext

    Reads one or more decimal digits and returns them as a number. A sign is not part
    of the syntax here, use [mrow.integer] for that.

    ```luau
    mrow.create(mrow.unsigned_integer)("0042").value --> 42
    mrow.create(mrow.unsigned_integer)("-1").success --> false
    ```
]=]
return function(context: parser.ParserContext)
    const source = context.source
    const start_offset = context.offset
    local offset = start_offset

    while true do
        const byte = string.byte(source, offset)

        -- 0-9
        if not byte or byte < 48 or byte > 57 then
            break
        end

        offset += 1
    end

    if start_offset == offset then
        const char = parser.peek(context)
        context.return_error = if char
            then `expected unsigned int, but got '{char}'`
            else "expected unsigned int, but got end of input"
        return
    end

    const uint_str = string.sub(source, start_offset, offset - 1)
    const uint = tonumber(uint_str)

    if not uint then
        context.return_error = `expected unsigned int, but got '{uint_str}'`
        return
    end

    context.offset = offset
    context.return_value = uint
end
