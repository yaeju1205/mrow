const parser = require("../parser")

--[=[
    @tag combinator
    @param target ParserFrame
    @param transform (any) -> any -- Receives the value `target` produced
    @return ParserFrame

    Runs `target` and hands its value to `transform`, so a parser can produce a value
    of your own shape instead of the raw characters it matched. `transform` is not
    called when `target` fails.

    ```luau
    const word = mrow.map(mrow.some(mrow.one_of("abc")), function(chars: { string }): string
        return table.concat(chars)
    end)

    mrow.create(word)("cab").value --> "cab"
    ```
]=]
return function(target: parser.ParserFrame, transform: (any) -> any): parser.ParserFrame
    const function after_target(context: parser.ParserContext)
        if context.return_error then
            return
        end

        context.return_value = transform(context.return_value)
    end

    return function(context: parser.ParserContext)
        parser.stack_frame_push(context, after_target)
        parser.stack_frame_push(context, target)
    end
end
