print("Recursive")

const mrow = require("../src")

local recursvie_parser

recursvie_parser = mrow.lazy(function()
    return mrow.choice(
        mrow.between(
            mrow.one_of("("),
            recursvie_parser,
            mrow.one_of(")")
        ),
        mrow.integer
    )
end)

const parser = mrow.create(recursvie_parser )
const start_clock = os.clock()
const result = parser(
    string.rep("(", 10 ^ 5)
    ..
    "0"
    ..
    string.rep(")", 10 ^ 5)

)

print("time:", os.clock() - start_clock)
print("success:", result.success)
print("depth:", 10 ^ 5)

if result.success then
    print(result.value)
else
    print(result.error)
end
