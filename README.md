# mrow

A parser combinator library for Luau. Parsers push frames onto an explicit stack
instead of calling each other, so deeply nested input never overflows the call stack.
It also supports left recursion and reads input as UTF-8.

```luau
const mrow = require(path to require)

const number = mrow.token(mrow.integer)
const list = mrow.between(
    mrow.token(mrow.string("[")),
    mrow.separated(number, mrow.token(mrow.string(","))),
    mrow.token(mrow.string("]"))
)

const parse = mrow.create(mrow.between(mrow.spaces, list, mrow.eof))

parse(" [1, 2, -3] ").value --> { 1, 2, -3 }
parse("[1, 2").error --> "expected ']', but got end of input"
```

`mrow.create(frame)` returns a function that turns a source string into
`{ success = true, value = ... }` or `{ success = false, error = "..." }`.
Every parser rewinds when it fails. End the grammar with `mrow.eof` when the whole
input has to match.

## Custom frames

A frame is a `(ParserContext) -> ()` function. To succeed, it sets
`context.return_value` and advances `context.offset`. To fail, it sets
`context.return_error`.

```luau
local function hex_digit(context: mrow.ParserContext)
    const char = mrow.parser.peek(context)

    if char and string.find(char, "^%x$") then
        mrow.parser.next(context)
        context.return_value = char
    else
        context.return_error = "expected hex digit"
    end
end
```