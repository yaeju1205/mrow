const mrow = require("../src")
const support = require("./support")

const ok, fails, equal = support.ok, support.fails, support.equal

-- string
do
    const let = mrow.string("let")
    equal(ok(mrow.parse("let", let)), "let")

    const parsed, data = support.run("les", let)
    fails(parsed)
    equal(data.char_index, 1, "string consumes nothing on failure")
end

-- satisfy
do
    const upper = mrow.satisfy("uppercase letter", function(char: string): boolean
        return char:lower() ~= char
    end)

    equal(ok(mrow.parse("A", upper)), "A")
    support.has_message(fails(mrow.parse("a", upper)), "expected uppercase letter, got 'a'")
end

-- any
equal(ok(mrow.parse("a", mrow.any)), "a")
fails(mrow.parse("", mrow.any))

-- one_of
do
    const digit = mrow.one_of("0123456789")
    equal(ok(mrow.parse("7", digit)), "7")
    fails(mrow.parse("x", digit))
end

-- none_of
do
    const text_char = mrow.none_of('"\\')
    equal(ok(mrow.parse("a", text_char)), "a")
    fails(mrow.parse('"', text_char))
end

-- spaces
equal(ok(mrow.parse("  \n", mrow.spaces)), "  \n")
equal(ok(mrow.parse_partial("a", mrow.spaces)), "")

-- eof
do
    const whole_line = mrow.sequence(mrow.some(mrow.none_of("\n")), mrow.eof)
    ok(mrow.parse_partial("abc", whole_line))
    fails(mrow.parse_partial("abc\n", whole_line))
end

print("atomic: ok")
return true
