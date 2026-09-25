local mrow = require("./src")

const result = mrow.parse(
    "aa",
    mrow.one_of("a")
)

if result.failed then
    print(result.error:format())
else
    print(result:unwrap())
end