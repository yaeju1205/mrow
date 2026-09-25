const parser = require("../parser")
const result = require("../result")

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
    return function(data: parser.ParserData): parser.ParserResult<T>
        const state = parser.save(data)

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

        return result.success(value:unwrap())
    end
end
