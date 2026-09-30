const parser = require("../parser")
const trampoline = require("../trampoline")

const CALL = trampoline.CALL

--[=[
    @tag combinator
    @param open Parser<O> -- Run first, its value is dropped
    @param inner Parser<T> -- The value that is kept
    @param close Parser<C> -- Run last, its value is dropped
    @return Parser<T>

    Runs `open`, `inner` and `close` in order and keeps only what `inner` produced.
    A failure after `open` rewinds to where the whole parser started.

    ```luau
    const parens = mrow.between(mrow.string("("), mrow.integer, mrow.string(")"))
    mrow.parse("(-3)", parens):unwrap() --> -3
    mrow.parse("(-3", parens).failed --> true
    ```
]=]
return function<O, T, C>(open: parser.Parser<O>, inner: parser.Parser<T>, close: parser.Parser<C>): parser.Parser<T>
    if trampoline.is_leaves(open, inner, close) then
        return trampoline.leaf(function(data: parser.ParserData): parser.ParserResult<T>
            const state = parser.store(data)

            const opened = open(data)
            if opened.failed then
                return opened
            end

            const value = inner(data)
            if value.failed then
                parser.restore(data, state)

                return value
            end

            const closed = close(data)
            if closed.failed then
                parser.restore(data, state)

                return closed
            end

            return parser.success(value:unwrap())
        end)
    end

    const open_is_leaf = trampoline.is_leaves(open)
    const inner_is_leaf = trampoline.is_leaves(inner)
    const close_is_leaf = trampoline.is_leaves(close)

    -- Leaves are called right here; only the others go through the trampoline and
    -- cost a continuation. For `between(open, lazy(...), close)` that is one.
    const function after_inner(data: parser.ParserData, state: parser.ParserPosition, value: any): ...any
        if value.failed then
            parser.restore(data, state)

            return value
        end

        if close_is_leaf then
            const closed = close(data)
            if closed.failed then
                parser.restore(data, state)

                return closed
            end

            return value
        end

        const function after_close(closed: any): ...any
            if closed.failed then
                parser.restore(data, state)

                return closed
            end

            return value
        end

        return CALL, close, after_close
    end

    const function after_open(data: parser.ParserData, state: parser.ParserPosition): ...any
        if inner_is_leaf then
            return after_inner(data, state, inner(data))
        end

        const function continue(value: any): ...any
            return after_inner(data, state, value)
        end

        return CALL, inner, continue
    end

    return function(data: parser.ParserData): ...any
        const state = parser.store(data)

        if open_is_leaf then
            const opened = open(data)
            if opened.failed then
                return opened
            end

            return after_open(data, state)
        end

        const function continue(opened: any): ...any
            if opened.failed then
                return opened
            end

            return after_open(data, state)
        end

        return CALL, open, continue
    end
end
