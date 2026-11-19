const parser = require("../parser")

--[=[
    @tag combinator
    @param item ParserFrame
    @return ParserFrame

    Turns a failure of `item` into a success holding `nil`, so a piece of syntax may
    simply be absent. A missing match rewinds to where `item` started, however far it
    got before failing.

    ```luau
    const sign = mrow.optional(mrow.string("-"))
    mrow.create(sign)("-1").value --> "-"
    mrow.create(sign)("1").value --> nil
    ```
]=]
return function(item: parser.ParserFrame): parser.ParserFrame
    -- Value stack: where the item started.
    const function after_item(context: parser.ParserContext)
        const start: number = parser.stack_value_pop(context)

        if context.return_error then
            context.return_error = nil
            context.return_value = nil
            context.offset = start
        end
    end

    return function(context: parser.ParserContext)
        parser.stack_value_push(context, context.offset)
        parser.stack_frame_push(context, after_item)
        parser.stack_frame_push(context, item)
    end
end
