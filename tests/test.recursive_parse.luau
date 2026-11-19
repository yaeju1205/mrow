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

const depth = 10 ^ 4

const parser = mrow.create(recursvie_parser )
const start_clock = os.clock()
const result = parser(
    string.rep("(", depth)
    ..
    "0"
    ..
    string.rep(")", depth)

)

print("time:", os.clock() - start_clock)
print("success:", result.success)
print("depth:", depth)

if result.success then
    print(result.value)
else
    print(result.error)
end
