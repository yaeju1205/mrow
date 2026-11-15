const parser = require("../parser")

--[=[
    @tag atomic
    @param context ParserContext

    Consumes whitespace (space, `\t`, `\n`, `\r`) until something else shows up,
    and returns the text it ate. Never fails: eating nothing is a success with `""`.

    ```luau
    mrow.create(mrow.spaces)("  \n").value --> "  \n"
    mrow.create(mrow.spaces)("a").value --> ""
    ```
]=]
return function(context: parser.ParserContext)
    const source = context.source
    const start_offset = context.offset
    local offset = start_offset

    while true do
        const byte = string.byte(source, offset)

        if byte ~= 32 and byte ~= 9 and byte ~= 10 and byte ~= 13 then
            break
        end

        offset += 1
    end

    context.offset = offset
    context.return_value = string.sub(source, start_offset, offset - 1)
end
