const parser = require("../parser")

--[=[
    @tag combinator
    @param ... ParserFrame -- Run one after another
    @return ParserFrame -- Produces a table of every value, in order

    Runs every parser in order and collects what each one produced, so the value of
    the `n`th parser is at index `n`. A parser that produces `nil` leaves a hole at its
    index, so read the values by index rather than with `#` or `ipairs`. As soon as one
    of them fails, the whole sequence fails.

    ```luau
    const assignment = mrow.sequence(mrow.string("a"), mrow.string("="), mrow.unsigned_integer)
    mrow.create(assignment)("a=1").value --> { "a", "=", 1 }
    mrow.create(assignment)("a=x").success --> false
    ```
]=]
return function(...: parser.ParserFrame): parser.ParserFrame
    const frames = { ... }
    const frame_count = #frames

    -- Value stack: the values so far.
    const steps: { parser.ParserFrame } = {}

    for index = 1, frame_count do
        steps[index] = function(context: parser.ParserContext)
            const values: { any } = parser.stack_value_pop(context)

            if context.return_error then
                return
            end

            values[index] = context.return_value

            if index == frame_count then
                context.return_value = values
                return
            end

            parser.stack_value_push(context, values)
            parser.stack_frame_push(context, steps[index + 1])
            parser.stack_frame_push(context, frames[index + 1])
        end
    end

    return function(context: parser.ParserContext)
        if frame_count == 0 then
            context.return_value = {}
            return
        end

        parser.stack_value_push(context, {})
        parser.stack_frame_push(context, steps[1])
        parser.stack_frame_push(context, frames[1])
    end
end
