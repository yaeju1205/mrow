const parser = require("../parser")

--[=[
    @tag combinator
    @param item ParserFrame
    @return ParserFrame -- Produces a table of every value `item` produced

    Like [mrow.many], but demands at least one match: with none, it fails with the
    error `item` gave.

    ```luau
    const digits = mrow.some(mrow.one_of("0123456789"))
    #mrow.create(digits)("42").value --> 2
    mrow.create(digits)("").success --> false
    ```
]=]
return function(item: parser.ParserFrame): parser.ParserFrame
    -- Value stack: the values, their count, and where the last item started.
    local after_item: parser.ParserFrame
    after_item = function(context: parser.ParserContext)
        const before: number = parser.stack_value_pop(context)
        local count: number = parser.stack_value_pop(context)
        const values: { any } = parser.stack_value_pop(context)

        if context.return_error then
            if count == 0 then
                return
            end

            context.return_error = nil
            context.offset = before
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
