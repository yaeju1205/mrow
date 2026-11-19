const mrow = require("../src")

local left_recursvie

left_recursvie = mrow.left_recursive(function()
    return mrow.choice(
        mrow.sequence(left_recursvie, mrow.one_of("$")),
        mrow.sequence()
    )
end)

const depth = 10 ^ 6

const parser = mrow.create(left_recursvie)
const start_clock = os.clock()
const result = parser(string.rep("$", depth))

print("time:", os.clock() - start_clock)
print("success:", result.success)
print("depth:", depth)

if result.success then
    print(result.value)
else
    print(result.error)
end
