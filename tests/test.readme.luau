--!nocheck

const mrow = require("../src")

const number = mrow.token(mrow.integer)
const list = mrow.between(
    mrow.token(mrow.string("[")),
    number,
    mrow.token(mrow.string("]"))
)

const parse = mrow.create(mrow.between(mrow.spaces, list, mrow.eof))

print(parse(" [1] ").value) --> 1
print(parse("[1").error) --> "expected ']', but got end of input"
