const parser = require("../parser")

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
    local frame: parser.ParserFrame? = nil

    -- `entries[start]` is `true` while the rule runs at `start`, or a seed table
    -- `{ offset, value }` once it recursed there (`offset` is nil until it has grown one).
    local after_rule: parser.ParserFrame
    -- Value stack: the entries of this rule, and where this run started.
    after_rule = function(context: parser.ParserContext)
        const start: number = parser.stack_value_pop(context)
        const entries: { [number]: any } = parser.stack_value_pop(context)
        const state = entries[start]

        if context.return_error then
            entries[start] = nil

            if state ~= true and state.offset then
                context.return_error = nil
                context.offset = state.offset
                context.return_value = state.value
            end
            return
        end

        if state == true then
            -- Never reached itself, so the first result is final.
            entries[start] = nil
            return
        end

        const seed_offset = state.offset

        if seed_offset and context.offset <= seed_offset then
            -- Stopped growing, the last seed is the answer.
            entries[start] = nil
            context.offset = seed_offset
            context.return_value = state.value
            return
        end

        state.offset = context.offset
        state.value = context.return_value

        context.offset = start
        parser.stack_value_push(context, entries)
        parser.stack_value_push(context, start)
        parser.stack_frame_push(context, after_rule)
        parser.stack_frame_push(context, frame :: parser.ParserFrame)
    end

    return function(context: parser.ParserContext)
        const rule: parser.ParserFrame = frame or make_frame()
        frame = rule

        -- Keyed by the rule rather than by this lazy, so every reference to one rule
        -- shares the same seed.
        const running = context.running
        local entries = running[rule]
        if not entries then
            entries = {}
            running[rule] = entries
        end

        const offset = context.offset
        const state = entries[offset]

        -- Left-recursive call: answer with what the running call has grown so far.
        if state ~= nil then
            if state == true then
                entries[offset] = { offset = nil, value = nil }
                context.return_error = "left recursion has no result yet"
            elseif state.offset then
                context.offset = state.offset
                context.return_value = state.value
            else
                context.return_error = "left recursion has no result yet"
            end
            return
        end

        entries[offset] = true

        parser.stack_value_push(context, entries)
        parser.stack_value_push(context, offset)
        parser.stack_frame_push(context, after_rule)
        parser.stack_frame_push(context, rule)
    end
end
