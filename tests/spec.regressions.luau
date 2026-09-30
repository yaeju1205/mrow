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

print("regressions: ok")
return true
