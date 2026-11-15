const parser = require("../parser")

--[=[
    @tag combinator
    @param open ParserFrame -- Run first, its value is dropped
    @param inner ParserFrame -- The value that is kept
    @param close ParserFrame -- Run last, its value is dropped
    @return ParserFrame

    Runs `open`, `inner` and `close` in order and keeps only what `inner` produced.
    A failure after `open` rewinds to where the whole parser started.

    ```luau
    const parens = mrow.between(mrow.string("("), mrow.integer, mrow.string(")"))
    mrow.create(parens)("(-3)").value --> -3
    mrow.create(parens)("(-3").success --> false
    ```
]=]
return function(open: parser.ParserFrame, inner: parser.ParserFrame, close: parser.ParserFrame): parser.ParserFrame
    -- Value stack: start, then (after inner) the value of inner.
    const function after_close(context: parser.ParserContext)
        const value = parser.stack_value_pop(context)
        const start: number = parser.stack_value_pop(context)

        if context.return_error then
            context.offset = start
            return
        end

        context.return_value = value
    end

    const function after_inner(context: parser.ParserContext)
        if context.return_error then
            context.offset = parser.stack_value_pop(context)
            return
        end

        parser.stack_value_push(context, context.return_value)
        parser.stack_frame_push(context, after_close)
        parser.stack_frame_push(context, close)
    end

    const function after_open(context: parser.ParserContext)
        if context.return_error then
            context.offset = parser.stack_value_pop(context)
            return
        end

        parser.stack_frame_push(context, after_inner)
        parser.stack_frame_push(context, inner)
    end

    return function(context: parser.ParserContext)
        parser.stack_value_push(context, context.offset)
        parser.stack_frame_push(context, after_open)
        parser.stack_frame_push(context, open)
    end
end
