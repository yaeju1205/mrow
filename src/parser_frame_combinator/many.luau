const parser = require("../parser")

--[=[
    @tag combinator
    @param item ParserFrame
    @return ParserFrame -- Produces a table of every value `item` produced

    Runs `item` over and over until it fails, and collects every value it produced.
    Never fails: zero matches is a success holding an empty table — use [mrow.some]
    to demand at least one. An `item` that succeeds without moving the position ends
    the loop instead of spinning forever.

    ```luau
    const digits = mrow.many(mrow.one_of("0123456789"))
    #mrow.create(digits)("123").value --> 3
    #mrow.create(digits)("").value --> 0
    ```
]=]
return function(item: parser.ParserFrame): parser.ParserFrame
    -- Value stack: the values so far, how many there are (kept apart from `#values`,
    -- so items that produce `nil` keep their place), and where the last item started.
    local after_item: parser.ParserFrame
    after_item = function(context: parser.ParserContext)
        const before: number = parser.stack_value_pop(context)
        local count: number = parser.stack_value_pop(context)
        const values: { any } = parser.stack_value_pop(context)

        if context.return_error then
            context.return_error = nil
            context.return_value = values
            return
        end

        count += 1
        values[count] = context.return_value

        if context.offset == before then
            context.return_value = values
            return
        end

        parser.stack_value_push(context, values)
        parser.stack_value_push(context, count)
        parser.stack_value_push(context, context.offset)
        parser.stack_frame_push(context, after_item)
        parser.stack_frame_push(context, item)
    end

    return function(context: parser.ParserContext)
        parser.stack_value_push(context, {})
        parser.stack_value_push(context, 0)
        parser.stack_value_push(context, context.offset)
        parser.stack_frame_push(context, after_item)
        parser.stack_frame_push(context, item)
    end
end
