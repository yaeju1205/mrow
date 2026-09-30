const mrow = require("../src")
const support = require("./support")

const ok, fails, equal, list_equal = support.ok, support.fails, support.equal, support.list_equal

-- choice
do
    const boolean = mrow.choice(mrow.string("true"), mrow.string("false"))
    equal(ok(mrow.parse("false", boolean)), "false")
    fails(mrow.parse("maybe", boolean))
end

-- sequence
do
    const assignment = mrow.sequence(mrow.string("a"), mrow.string("="), mrow.natural)
    ok(mrow.parse("a=1", assignment))

    const parsed, data = support.run("a=x", assignment)
    fails(parsed)
    equal(data.char_index, 1, "sequence consumes nothing on failure")
end

-- many
do
    const digits = mrow.many(mrow.one_of("0123456789"))
    equal(#ok(mrow.parse("123", digits)), 3)
    equal(#ok(mrow.parse("", digits)), 0)
end

-- some
do
    const digits = mrow.some(mrow.one_of("0123456789"))
    equal(#ok(mrow.parse("42", digits)), 2)
    fails(mrow.parse("", digits))
end

-- optional
do
    const sign = mrow.optional(mrow.string("-"))
    equal(ok(mrow.parse_partial("-1", sign)), "-")
    equal(ok(mrow.parse_partial("1", sign)), nil)
end

-- map
do
    const word = mrow.map(mrow.some(mrow.one_of("abc")), function(chars: { string }): string
        return table.concat(chars)
    end)

    equal(ok(mrow.parse("cab", word)), "cab")
end

-- between
do
    const parens = mrow.between(mrow.string("("), mrow.integer, mrow.string(")"))
    equal(ok(mrow.parse("(-3)", parens)), -3)

    const errors = fails(mrow.parse("(1", parens))
    equal(errors.errors[1].position.column, 3, "caret points one past '1'")
end

-- separated
do
    const list = mrow.separated(mrow.integer, mrow.string(","))
    list_equal(ok(mrow.parse("1,2,3", list)), { 1, 2, 3 })
    list_equal(ok(mrow.parse("", list)), {})
end

-- token
do
    const number = mrow.token(mrow.integer)
    const list = mrow.separated(number, mrow.token(mrow.string(",")))

    list_equal(ok(mrow.parse("1, 2, 3", list)), { 1, 2, 3 })
end

-- lazy
do
    local expression: mrow.Parser<number>

    const atom = mrow.choice(
        mrow.integer,
        mrow.between(
            mrow.string("("),
            mrow.lazy(function()
                return expression
            end),
            mrow.string(")")
        )
    )

    expression = mrow.map(mrow.separated(atom, mrow.string("+")), function(terms: { number }): number
        local sum = 0
        for _, term in terms do
            sum += term
        end
        return sum
    end)

    equal(ok(mrow.parse("1+(2+3)", expression)), 6)
end

-- label
do
    const identifier = mrow.label("identifier", mrow.some(mrow.one_of("abcdefghijklmnopqrstuvwxyz")))
    support.has_message(fails(mrow.parse("1", identifier)), "expected identifier")
end

-- README / init.luau example
do
    const point = mrow.between(
        mrow.token(mrow.string("(")),
        mrow.map(mrow.separated(mrow.token(mrow.integer), mrow.token(mrow.string(","))), function(values: { number })
            return { x = values[1], y = values[2] }
        end),
        mrow.token(mrow.string(")"))
    )

    const value = ok(mrow.parse("(1, 2)", point))
    equal(value.x, 1, "x")
    equal(value.y, 2, "y")
end

print("combinate: ok")
return true
