const parser = require("../parser")

--[=[
    @tag combinator
    @param ... ParserFrame -- The alternatives, tried from left to right
    @return ParserFrame

    Returns the result of the first alternative that succeeds. The position is restored
    before each attempt, so alternatives are free to share a prefix. When they all fail,
    their errors are joined with ` or ` into one message that lists each thing that could
    have been there — wrap it in [mrow.label] to report one expectation instead.

    ```luau
    const boolean = mrow.choice(mrow.string("true"), mrow.string("false"))
    mrow.create(boolean)("false").value --> "false"
    mrow.create(boolean)("maybe").error
    --> "expected 'true', but got 'm' or expected 'false', but got 'm'"
    ```
]=]
return function(...: parser.ParserFrame): parser.ParserFrame
    const frames = { ... }
    const frame_count = #frames

    -- Value stack: the alternative that just ran, where they all start, and what the
    -- failed ones said so far.
    local step: parser.ParserFrame
    step = function(context: parser.ParserContext)
        local errors: string? = parser.stack_value_pop(context)
        const start: number = parser.stack_value_pop(context)
        const index: number = parser.stack_value_pop(context)
        const error = context.return_error

        if not error then
            return
        end

        if error ~= "left recursion has no result yet" then
            errors = if errors then `{errors} or {error}` else error
        end

        context.return_error = nil
        context.offset = start

        if index == frame_count then
            context.return_error = errors or "left recursion has no result yet"
            return
        end

        parser.stack_value_push(context, index + 1)
        parser.stack_value_push(context, start)
        parser.stack_value_push(context, errors)
        parser.stack_frame_push(context, step)
        parser.stack_frame_push(context, frames[index + 1])
    end

    return function(context: parser.ParserContext)
        if frame_count == 0 then
            context.return_error = "left recursion has no result yet"
            return
        end

        parser.stack_value_push(context, 1)
        parser.stack_value_push(context, context.offset)
        parser.stack_value_push(context, nil)
        parser.stack_frame_push(context, step)
        parser.stack_frame_push(context, frames[1])
    end
end
