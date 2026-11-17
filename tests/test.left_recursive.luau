const mrow = require("../src")

local left_recursvie

left_recursvie = mrow.lazy(function()
    return mrow.choice(
        mrow.one_of("$"),
        mrow.eof
    )
end)

local parser = mrow.create(left_recursvie)
local result = parser(string.rep("$", 10000))

if result.success then
    print(result.value)
else
    print(result.error)
end

return nil
