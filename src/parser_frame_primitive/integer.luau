const parser = require("../parser")
const unsigned_integer = require("./unsigned_integer")

--[=[
    @tag primitive
    @param context ParserContext

    Reads a decimal number with an optional leading `+` or `-`. A lone sign with no
    digits after it fails and consumes nothing.

    ```luau
    mrow.create(mrow.integer)("-42").value --> -42
    mrow.create(mrow.integer)("+7").value --> 7
    mrow.create(mrow.integer)("-").success --> false
    ```
]=]
return function(context: parser.ParserContext)
    const start_offset = context.offset
    local sign = 1

    const sign_byte = string.byte(context.source, start_offset)
    if sign_byte == 45 then -- -
        sign = -1
        context.offset += 1
    elseif sign_byte == 43 then -- +
        context.offset += 1
    end

    unsigned_integer(context)

    if context.return_error then
        context.offset = start_offset
        return
    end

    context.return_value *= sign
end
