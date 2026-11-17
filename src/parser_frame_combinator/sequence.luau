const parser = require("../parser")

--[=[
    @tag combinator
    @param ... ParserFrame -- Run one after another
    @return ParserFrame -- Produces a table of every value, in order

    Runs every parser in order and collects what each one produced, so the value of
    the `n`th parser is at index `n`. A parser that produces `nil` leaves a hole at its
    index, so read the values by index rather than with `#` or `ipairs`. As soon as one
    of them fails the whole sequence fails and rewinds to where it started.

    ```luau
    const assignment = mrow.sequence(mrow.string("a"), mrow.string("="), mrow.unsigned_integer)
    mrow.create(assignment)("a=1").value --> { "a", "=", 1 }
    mrow.create(assignment)("a=x").success --> false -- and nothing was consumed
    ```
]=]
return function(...: parser.ParserFrame): parser.ParserFrame
    const frames = { ... }
    const frame_count = #frames

    -- Value stack: the values so far, the parser that just ran, and where the sequence
    -- started.
    local step: parser.ParserFrame
    step = function(context: parser.ParserContext)
        const start: number = parser.stack_value_pop(context)
        const index: number = parser.stack_value_pop(context)
        const values: { any } = parser.stack_value_pop(context)

        if context.return_error then
            context.offset = start
            return
        end

        values[index] = context.return_value

        if index == frame_count then
            context.return_value = values
            return
        end

        parser.stack_value_push(context, values)
        parser.stack_value_push(context, index + 1)
        parser.stack_value_push(context, start)
        parser.stack_frame_push(context, step)
        parser.stack_frame_push(context, frames[index + 1])
    end

    return function(context: parser.ParserContext)
        if frame_count == 0 then
            context.return_value = {}
            return
        end

        parser.stack_value_push(context, {})
        parser.stack_value_push(context, 1)
        parser.stack_value_push(context, context.offset)
        parser.stack_frame_push(context, step)
        parser.stack_frame_push(context, frames[1])
    end
end
