const parser = require("../parser")

--[=[
    @tag combinator
    @param item ParserFrame
    @return ParserFrame

    Turns a failure of `item` into a success holding `nil`, so a piece of syntax may
    simply be absent. Every parser in this library rewinds itself when it fails, so a
    missing match leaves the position untouched.

    ```luau
    const sign = mrow.optional(mrow.string("-"))
    mrow.create(sign)("-1").value --> "-"
    mrow.create(sign)("1").value --> nil
    ```
]=]
return function(item: parser.ParserFrame): parser.ParserFrame
    const function after_item(context: parser.ParserContext)
        if context.return_error then
            context.return_error = nil
            context.return_value = nil
        end
    end

    return function(context: parser.ParserContext)
        parser.stack_frame_push(context, after_item)
        parser.stack_frame_push(context, item)
    end
end
