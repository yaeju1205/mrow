const mrow = require("../src")
const support = require("./support")

const ok, fails, equal = support.ok, support.fails, support.equal

-- natural
equal(ok(mrow.parse("0042", mrow.natural)), 42)
fails(mrow.parse("-1", mrow.natural))

-- integer
equal(ok(mrow.parse("-42", mrow.integer)), -42)
equal(ok(mrow.parse("+7", mrow.integer)), 7)
fails(mrow.parse("-", mrow.integer))

print("primitive: ok")
return true
