const parser = require("../parser")

type Seed = {
    offset: number?,
    value: any,
}

type SeedRegistry = { [number]: Seed }

const RUNNING: Seed = table.freeze({ offset = nil, value = nil })

--[=[
    @tag combinator
    @param make_frame () -> ParserFrame -- Called once, the first time the parser runs
    @return ParserFrame

    Defers building a parser until it first runs, then keeps it. This is what ties a
    recursive grammar together, where a parser has to mention itself before it exists.
    Combinators push frames onto the context's stack instead of calling each other, so
    deeply nested input does not grow the Luau call stack.

    Left recursion is supported. When the rule reaches itself again before consuming
    any input, that inner call fails at first, and then gets back the longest result
    found so far; the rule is rerun until its result stops growing, which makes
    `a - b - c` parse as `(a - b) - c`. For this to work every call of the rule has to
    go through `lazy`, including the outermost one, so define the rule as the `lazy`
    itself:

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

    local after_frame: parser.ParserFrame
    after_frame = function(context: parser.ParserContext)
        const start: number = parser.stack_value_pop(context)
        const seed_registry: SeedRegistry = parser.stack_value_pop(context)
        const seed = seed_registry[start]

        if seed ~= RUNNING and not context.return_error and (not seed.offset or context.offset > seed.offset) then
            seed.offset = context.offset
            seed.value = context.return_value

            context.offset = start
            parser.stack_value_push(context, seed_registry)
            parser.stack_value_push(context, start)
            parser.stack_frame_push(context, after_frame)
            parser.stack_frame_push(context, frame)
            return
        end

        seed_registry[start] = nil

        if seed.offset then
            context.return_error = nil
            context.offset = seed.offset
            context.return_value = seed.value
        end
    end

    return function(context: parser.ParserContext)
        frame = frame or make_frame()

        const running_seeds: { [parser.ParserFrame]: SeedRegistry } = context.running
        local seed_registry = running_seeds[frame]

        if not seed_registry then
            seed_registry = {}
            running_seeds[frame] = seed_registry
        end

        const offset = context.offset
        local seed: Seed? = seed_registry[offset]

        if seed then
            if seed == RUNNING then
                seed = { offset = nil, value = nil }
                seed_registry[offset] = seed
            end

            if seed.offset then
                context.offset = seed.offset
                context.return_value = seed.value
            else
                context.return_error = "left recursion has no result yet"
            end
            return
        end

        seed_registry[offset] = RUNNING

        parser.stack_value_push(context, seed_registry)
        parser.stack_value_push(context, offset)
        parser.stack_frame_push(context, after_frame)
        parser.stack_frame_push(context, frame)
    end
end
