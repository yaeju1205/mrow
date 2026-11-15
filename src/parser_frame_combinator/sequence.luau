const parser = require("../parser")

--[=[
    @tag combinator
    @param ... ParserFrame -- Run one after another
    @return ParserFrame -- Succeeds with `nil`

    Runs every parser in order and throws their values away; use it to match a shape
    you only need to check. As soon as one of them fails the whole sequence fails and
    rewinds to where it started. To keep a value out of the middle, reach for
    [mrow.between] or give the pieces to [mrow.map] yourself.

    ```luau
    const assignment = mrow.sequence(mrow.string("a"), mrow.string("="), mrow.unsigned_integer)
    mrow.create(assignment)("a=1").success --> true
    mrow.create(assignment)("a=x").success --> false -- and nothing was consumed
    ```
]=]
return function(...: parser.ParserFrame): parser.ParserFrame
    const frames = { ... }
    const frame_count = #frames

    -- Value stack: the parser that just ran, and where the sequence started.
    local step: parser.ParserFrame
    step = function(context: parser.ParserContext)
        const start: number = parser.stack_value_pop(context)
        const index: number = parser.stack_value_pop(context)

        if context.return_error then
            context.offset = start
            return
        end

        if index == frame_count then
            context.return_value = nil
            return
        end

        parser.stack_value_push(context, index + 1)
        parser.stack_value_push(context, start)
        parser.stack_frame_push(context, step)
        parser.stack_frame_push(context, frames[index + 1])
    end

    return function(context: parser.ParserContext)
        if frame_count == 0 then
            context.return_value = nil
            return
        end

        parser.stack_value_push(context, 1)
        parser.stack_value_push(context, context.offset)
        parser.stack_frame_push(context, step)
        parser.stack_frame_push(context, frames[1])
    end
end
