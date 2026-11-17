const parser = require("../parser")

--[=[
    @tag combinator
    @param make_frame () -> ParserFrame -- Called once, the first time the parser runs
    @return ParserFrame

    Defers building a parser until it first runs, then keeps it. This is what ties a
    recursive grammar together, where a parser has to mention itself before it exists.
    Combinators push frames onto the context's stack instead of calling each other, so
    deeply nested input does not grow the Luau call stack.

    ```luau
    local expression: mrow.ParserFrame

    expression = mrow.lazy(function()
        return mrow.choice(
            mrow.sequence(expression, mrow.string("+"), mrow.integer),
            mrow.integer
        )
    end)

    mrow.create(mrow.sequence(expression, mrow.eof))("1+2+3").success --> true
    ```

    Plain recursion needs nothing special:

    ```luau
    local expression: mrow.ParserFrame

    const atom = mrow.choice(
        mrow.integer,
        mrow.between(mrow.string("("), mrow.lazy(function()
            return expression
        end), mrow.string(")"))
    )

    expression = mrow.map(mrow.separated(atom, mrow.string("+")), function(terms: { number }): number
        local sum = 0
        for _, term in terms do
            sum += term
        end
        return sum
    end)

    mrow.create(expression)("1+(2+3)").value --> 6
    ```
]=]
return function(make_frame: () -> parser.ParserFrame): parser.ParserFrame
    local frame: parser.ParserFrame

    return function(context: parser.ParserContext)
        frame = frame or make_frame()

        parser.stack_frame_push(context, frame)
    end
end
