const parser = require("../parser")

--[=[
    @tag combinator
    @param description string -- Reported as `expected {description}`
    @param target ParserFrame
    @return ParserFrame

    Replaces whatever error `target` failed with by a single `expected {description}`
    and rewinds to where `target` started, so a deep grammar reports one readable
    expectation instead of every internal attempt it made.

    ```luau
    const identifier = mrow.label("identifier", mrow.some(mrow.one_of("abcdefghijklmnopqrstuvwxyz")))
    mrow.create(identifier)("1").error --> "expected identifier"
    ```
]=]
return function(description: string, target: parser.ParserFrame): parser.ParserFrame
    const message = `expected {description}`

    const function after_target(context: parser.ParserContext)
        const start: number = parser.stack_value_pop(context)

        if context.return_error then
            context.offset = start
            context.return_error = message
        end
    end

    return function(context: parser.ParserContext)
        parser.stack_value_push(context, context.offset)
        parser.stack_frame_push(context, after_target)
        parser.stack_frame_push(context, target)
    end
end
