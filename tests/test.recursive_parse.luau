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

local parser = mrow.create(recursvie_parser )
local result = parser(
    string.rep("(", 100000)
    ..
    "0"
    ..
    string.rep(")", 100000)

)

if result.success then
    print(result.value)
else
    print(result.error)
end
