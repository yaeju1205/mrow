# mrow

A parser combinator library for [Luau](https://luau.org). Parsers never throw — they
return a result you check.

## Usage

```luau
const mrow = require(path to require)

const point = mrow.between(
  mrow.token(mrow.string("(")),
  mrow.map(
    mrow.separated(
      mrow.token(mrow.integer),
      mrow.token(mrow.string(","))
    ),
    function(values: { number })
      return {
        x = values[1],
        y = values[2],
      }
    end
  ),
  mrow.token(mrow.string(")"))
)

const parsed = mrow.parse("(1, 2)", point)

if parsed.failed then
  print(parsed.error:format())
else
  const value = parsed:unwrap()
  print(value.x, value.y) --> 1 2
end
```
