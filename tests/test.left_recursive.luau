const mrow = require("../src")

local left_recursvie

left_recursvie = mrow.lazy(function()
    return mrow.choice(
        mrow.sequence(left_recursvie, mrow.one_of("$")),
        mrow.sequence()
    )
end)

const parser = mrow.create(left_recursvie)
const start_clock = os.clock()
const result = parser(string.rep("$", 10 ^ 6))

print("time:", os.clock() - start_clock)
print("success:", result.success)
print("depth:", 10 ^ 6)

if result.success then
    print(result.value)
else
    print(result.error)
end
