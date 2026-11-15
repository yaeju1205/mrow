const parser = require("../parser")
const spaces = require("../parser_frame_atomic/spaces")

const function after_target(context: parser.ParserContext)
    if context.return_error then
        return
    end

    const value = context.return_value

    spaces(context)

    context.return_value = value
end

--[=[
    @tag combinator
    @param target ParserFrame
    @return ParserFrame

    Runs `target` and then eats the whitespace behind it, so the next parser always
    starts on meaningful input. Leading whitespace is nobody's token — eat it once, at
    the very start of the grammar, and let every token clean up after itself.

    ```luau
    const number = mrow.token(mrow.integer)
    const list = mrow.separated(number, mrow.token(mrow.string(",")))

    mrow.create(list)("1, 2, 3").value --> { 1, 2, 3 }
    ```
]=]
return function(target: parser.ParserFrame): parser.ParserFrame
    return function(context: parser.ParserContext)
        parser.stack_frame_push(context, after_target)
        parser.stack_frame_push(context, target)
    end
end
