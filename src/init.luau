const parser = require("@self/parser")
const int = require("@self/parser_frame_primitive/integer")

const res = parser.create<<number>>(int)("-1234")

if res.success then
    print(res.value)
end
