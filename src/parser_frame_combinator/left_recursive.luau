const parser = require("../parser")

--[=[
    @tag combinator
    @param make_frame () -> ParserFrame -- Called once, the first time the parser runs
    @return ParserFrame

    Like [mrow.lazy], but for a rule that reaches itself before consuming any input.
    That inner call fails at first, then answers with the longest result found so far,
    and the rule reruns until its result stops growing, so `1-2-3` reads as
    `(1-2)-3`. Every call of the rule has to go through this, including the outermost
    one, so define the rule itself with it.

    ```luau
    local difference: mrow.ParserFrame

    difference = mrow.left_recursive(function()
        return mrow.choice(
            mrow.sequence(difference, mrow.string("-"), mrow.integer),
            mrow.integer
        )
    end)

    mrow.create(mrow.sequence(difference, mrow.eof))("1-2-3").success --> true
    ```
]=]
return function(make_frame: () -> parser.ParserFrame): parser.ParserFrame
    local frame: parser.ParserFrame

    -- Value stack: where the outer call of this rule started.
    local after_frame: parser.ParserFrame
    after_frame = function(context: parser.ParserContext)
        const outer: number = parser.stack_value_pop(context)
        -- Inner calls have restored it to ours.
        const start = context.running[frame]
        const seeds = context.seeds[frame]
        const seed = seeds and seeds[start]

        if seed and not context.return_error and (not seed.offset or context.offset > seed.offset) then
            seed.offset = context.offset
            seed.value = context.return_value
            context.offset = start

            parser.stack_value_push(context, outer)
            parser.stack_frame_push(context, after_frame)
            parser.stack_frame_push(context, frame)
            return
        end

        context.running[frame] = outer

        if not seed then
            return
        end

        seeds[start] = nil

        if seed.offset then
            context.return_error = nil
            context.offset = seed.offset
            context.return_value = seed.value
        end
    end

    return function(context: parser.ParserContext)
        frame = frame or make_frame()

        -- Only the innermost running call can have started here.
        const running = context.running
        const outer = running[frame]
        const offset = context.offset

        if outer == offset then
            local seeds = context.seeds[frame]

            if not seeds then
                seeds = {}
                context.seeds[frame] = seeds
            end

            local seed = seeds[offset]

            if not seed then
                seed = { offset = nil, value = nil }
                seeds[offset] = seed
            end

            if seed.offset then
                context.offset = seed.offset
                context.return_value = seed.value
            else
                context.return_error = "left recursion has no result yet"
            end
            return
        end

        running[frame] = offset

        parser.stack_value_push(context, outer)
        parser.stack_frame_push(context, after_frame)
        parser.stack_frame_push(context, frame)
    end
end
