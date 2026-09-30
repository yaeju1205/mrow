const parser = require("../parser")

--[=[
    @tag combinator
    @param make () -> Parser<T...> -- Called once, the first time the parser runs
    @return Parser<T...>

    Defers building a parser until it first runs, then keeps it. This is what ties a
    recursive grammar together, where a parser has to mention itself before it exists.

    Let recursion go through `lazy` rather than a hand-written `function(data) return
    expression(data) end`: `lazy` hands each level back to the trampoline, so nesting
    depth is bounded by memory, while a plain call stacks up and overflows after a few
    thousand levels.

    ```luau
    local expression: mrow.Parser<number>

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

    mrow.parse("1+(2+3)", expression):unwrap() --> 6
    ```
]=]
return function<T...>(make: () -> parser.Parser<T...>): parser.Parser<T...>
    local made: parser.Parser<T...>? = nil

    return function(data: parser.ParserData): parser.ParserResult<T...>
        const target: parser.Parser<T...> = made or make()
        made = target

        -- Not a leaf, so whoever runs this goes through the trampoline: recursion
        -- always passes a lazy, and each level returns to the driver instead of
        -- stacking Lua calls. `target` itself answers straight away.
        return (target :: any)(data)
    end
end
