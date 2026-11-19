const parser = require("../parser")

--[=[
    @tag combinator
    @param open ParserFrame -- Run first, its value is dropped
    @param inner ParserFrame -- The value that is kept
    @param close ParserFrame -- Run last, its value is dropped
    @return ParserFrame

    Runs `open`, `inner` and `close` in order and keeps only what `inner` produced.
    As soon as one of them fails, the whole parser fails.

    ```luau
    const parens = mrow.between(mrow.string("("), mrow.integer, mrow.string(")"))
    mrow.create(parens)("(-3)").value --> -3
    mrow.create(parens)("(-3").success --> false
    ```
]=]
return function(open: parser.ParserFrame, inner: parser.ParserFrame, close: parser.ParserFrame): parser.ParserFrame
    -- Value stack: the value of inner.
    const function after_close(context: parser.ParserContext)
        const value = parser.stack_value_pop(context)

        if not context.return_error then
            context.return_value = value
        end
    end

    const function after_inner(context: parser.ParserContext)
        if context.return_error then
            return
        end

        parser.stack_value_push(context, context.return_value)
        parser.stack_frame_push(context, after_close)
        parser.stack_frame_push(context, close)
    end

    const function after_open(context: parser.ParserContext)
        if context.return_error then
            return
        end

        parser.stack_frame_push(context, after_inner)
        parser.stack_frame_push(context, inner)
    end

    return function(context: parser.ParserContext)
        parser.stack_frame_push(context, after_open)
        parser.stack_frame_push(context, open)
    end
end
