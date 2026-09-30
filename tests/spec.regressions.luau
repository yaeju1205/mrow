-- One block per bug from review/REVIEW.md, named by its ID. A block pins the
-- fixed behavior so the bug cannot come back unnoticed.
const mrow = require("../src")
const support = require("./support")

const ok, equal, list_equal = support.ok, support.equal, support.list_equal

-- Succeeds with two values: the integer, and a constant 5.
const function two(data: mrow.ParserData): mrow.ParserResult<number, number>
    const parsed = mrow.token(mrow.integer)(data)
    if parsed.failed then
        return parsed
    end

    return mrow.parser.success(parsed:unwrap(), 5)
end

-- Succeeds with zero values after reading "a". (Not `mrow.sequence`: its
-- `Parser<never>` type is T2, a separate item.)
const function unit_a(data: mrow.ParserData): mrow.ParserResult<()>
    const parsed = mrow.string("a")(data)
    if parsed.failed then
        return parsed
    end

    return mrow.parser.success()
end

-- B1: separated must stop when neither item nor separator moves the position
do
    ok(mrow.parse_partial("abc", mrow.separated(mrow.spaces, mrow.spaces)))
    ok(mrow.parse_partial("abc", mrow.separated(mrow.optional(mrow.string("x")), mrow.spaces)))
    ok(mrow.parse_partial("", mrow.separated(mrow.eof, mrow.spaces)))
end

-- B2: items that succeed with zero values must not throw
do
    ok(mrow.parse_partial("", mrow.many(mrow.eof)))

    const _, data = support.run("aaa", mrow.many(unit_a))
    equal(data.char_index, 4, "many(zero-value item) consumes every match")

    ok(mrow.parse("aaa", mrow.some(unit_a)))
    ok(mrow.parse("a,a,a", mrow.separated(unit_a, mrow.string(","))))
end

-- B3: items that succeed with several values keep only the first, one entry per match
do
    list_equal(ok(mrow.parse("1 2 3", mrow.many(two))), { 1, 2, 3 }, "many")
    list_equal(ok(mrow.parse("1 2 3", mrow.some(two))), { 1, 2, 3 }, "some")
    list_equal(ok(mrow.parse("1,2,3", mrow.separated(two, mrow.string(",")))), { 1, 2, 3 }, "separated")
end

-- B8: long tokens are linear, not quadratic (each took ~0.8 s at 100k before)
do
    const started = os.clock()

    ok(mrow.parse(string.rep(" ", 100000), mrow.spaces))
    ok(mrow.parse(string.rep("1", 100000), mrow.natural))

    const literal = string.rep("a", 50000)
    equal(ok(mrow.parse(literal, mrow.string(literal))), literal)

    const elapsed = os.clock() - started
    assert(elapsed < 0.5, `long tokens took {elapsed}s`)
end

-- B8: string compares char by char, not by prefix
do
    const abc = mrow.string("abc")

    support.has_message(support.fails(mrow.parse("xyz", abc)), "expected 'abc', got 'x'")
    support.has_message(support.fails(mrow.parse("abd", abc)), "got 'abd'")
    support.has_message(support.fails(mrow.parse("ab", abc)), "got end of input")

    equal(ok(mrow.parse_partial("가나다", mrow.string("가나"))), "가나")

    const parsed, data = support.run("가x", mrow.string("가나"))
    support.fails(parsed)
    equal(data.char_index, 1, "string consumes nothing on failure")
end

-- B6: natural names the character it found, and says end of input only at the end
do
    const has_message = support.has_message

    has_message(support.fails(mrow.parse("abc", mrow.natural)), "expected natural number, got 'a'")
    has_message(support.fails(mrow.parse("", mrow.natural)), "expected natural number, got end of input")
    has_message(support.fails(mrow.parse("가1", mrow.natural)), "expected natural number, got '가'")

    const signed = support.fails(mrow.parse("--5", mrow.integer))
    has_message(signed, "expected natural number, got '-'")
    equal(signed.errors[1].position.column, 2, "integer reports after the sign")
    has_message(support.fails(mrow.parse("-", mrow.integer)), "got end of input")
end

-- B7: recursion through lazy runs on the trampoline, not the Lua call stack
do
    local expression: mrow.Parser<number>
    expression = mrow.choice(
        mrow.integer,
        mrow.between(
            mrow.string("("),
            mrow.lazy(function()
                return expression
            end),
            mrow.string(")")
        )
    )

    const depth = 50000 -- the old limit was 6,663
    equal(ok(mrow.parse(string.rep("(", depth) .. "7" .. string.rep(")", depth), expression)), 7)

    -- an error raised deep inside keeps its own message
    local failing: mrow.Parser<number>
    failing = mrow.choice(
        mrow.map(mrow.string("x"), function(_: string): number
            error("callback failed", 0)
        end),
        mrow.between(
            mrow.string("("),
            mrow.lazy(function()
                return failing
            end),
            mrow.string(")")
        )
    )

    const ran, message = pcall(mrow.parse, string.rep("(", depth) .. "x" .. string.rep(")", depth), failing)
    assert(not ran, "expected the callback error to propagate")
    equal(message, "callback failed", "error message")

    -- a hand-written parser gets another, non-leaf parser's result through mrow.run
    const function doubled(data: mrow.ParserData): mrow.ParserResult<number>
        const parsed = mrow.run(expression, data)
        if parsed.failed then
            return parsed
        end

        return mrow.parser.success(parsed:unwrap() * 2)
    end

    equal(ok(mrow.parse("((21))", doubled)), 42)
end

print("regressions: ok")
return true
