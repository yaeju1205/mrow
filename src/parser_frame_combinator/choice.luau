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

    -- Value stack: where they all start, then the errors so far (from the second on).
    const steps: { parser.ParserFrame } = {}

    for index = 1, frame_count do
        steps[index] = function(context: parser.ParserContext)
            const errors: string? = if index > 1 then parser.stack_value_pop(context) else nil
            const start: number = parser.stack_value_pop(context)
            const error = context.return_error

            if not error then
                return
            end

            context.offset = start

            const joined = if errors then `{errors} or {error}` else error

            if index == frame_count then
                context.return_error = joined
                return
            end

            context.return_error = nil
            parser.stack_value_push(context, start)
            parser.stack_value_push(context, joined)
            parser.stack_frame_push(context, steps[index + 1])
            parser.stack_frame_push(context, frames[index + 1])
        end
    end

    return function(context: parser.ParserContext)
        if frame_count == 0 then
            context.return_error = "choice parser combinator: expected just parser, but got nothing"
            return
        end

        parser.stack_value_push(context, context.offset)
        parser.stack_frame_push(context, steps[1])
        parser.stack_frame_push(context, frames[1])
    end
end
