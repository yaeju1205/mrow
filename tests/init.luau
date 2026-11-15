const mrow = require("./src")

local left: mrow.ParserFrame

local sum = 0

left = mrow.lazy(function()
    return mrow.choice(
        mrow.map(
            mrow.sequence(
                left,
                mrow.token(mrow.string("+")),
                mrow.token(mrow.map(mrow.integer, function(i: number)
                    sum += i
                    return i
                end))
            ),
            function()
                return sum
            end
        ),
        mrow.token(mrow.map(mrow.integer, function(i: number)
            sum += i
            return i
        end))
    )
end)

local parser = mrow.create(mrow.between(mrow.spaces, left, mrow.eof))
local result = parser(string.rep("2 + ", 100000) .. "1")
if result.success then
    print(result.value)
else
    print(result.error)
end

local nested: mrow.ParserFrame

nested = mrow.lazy(function()
    return mrow.choice(
        mrow.map(
            mrow.between(
                mrow.token(mrow.string("{")),
                nested,
                mrow.token(mrow.string("}"))
            ),
            function(inner: number)
                return inner
            end
        ),
        mrow.integer
    )
end)

-- const rep_count = 200000
-- const start_clock = os.clock()
-- local parser = mrow.create(mrow.between(mrow.spaces, nested, mrow.eof))
-- local result = parser(
--     string.rep("{", rep_count) .. 
--     "2"
--     .. string.rep("}", rep_count)
-- )

-- print(os.clock() - start_clock)
-- if result.success then
--     print(result.value)
-- else
--     print(result.error)
-- end