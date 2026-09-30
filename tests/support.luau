const mrow = require("../src")

--[=[
    Assertion helpers shared by the spec files. Each one raises with the parser's
    error messages (or a short description) so a failing spec says why it failed.
]=]
const support = {}

const function describe(failed: mrow.ParserFailed): string
    const lines = {}

    for _, error in failed.errors do
        table.insert(lines, `{error.position.line}:{error.position.column}: {error.message}`)
    end

    return table.concat(lines, "\n")
end

function support.ok<T...>(parsed: mrow.ParserResult<T...>): T...
    if parsed.failed then
        error(`unexpected failure\n{describe(parsed)}`, 2)
    end

    return parsed:unwrap()
end

function support.fails<T...>(parsed: mrow.ParserResult<T...>): mrow.ParserFailed
    if not parsed.failed then
        error("expected failure, got success", 2)
    end

    return parsed
end

function support.has_message(failed: mrow.ParserFailed, needle: string)
    for _, error in failed.errors do
        if string.find(error.message, needle, 1, true) then
            return
        end
    end

    error(`expected a message containing '{needle}', got:\n{describe(failed)}`, 2)
end

function support.equal(actual: unknown, expected: unknown, what: string?)
    if actual ~= expected then
        error(`{what or "value"}: expected {expected}, got {actual}`, 2)
    end
end

function support.list_equal<T>(actual: { T }, expected: { T }, what: string?)
    const name = what or "list"

    if #actual ~= #expected then
        error(`{name}: expected {#expected} items, got {#actual}`, 2)
    end

    for i = 1, #expected do
        if actual[i] ~= expected[i] then
            error(`{name}[{i}]: expected {expected[i]}, got {actual[i]}`, 2)
        end
    end
end

function support.contains(text: string, needle: string, what: string?)
    if not string.find(text, needle, 1, true) then
        error(`{what or "text"}: expected to contain '{needle}', got:\n{text}`, 2)
    end
end

--[=[
    Runs `target` over `input` directly, so a spec can look at the position it left
    behind — the public `mrow.parse` hides that.
]=]
function support.run<T...>(input: string, target: mrow.Parser<T...>): (mrow.ParserResult<T...>, mrow.ParserData)
    const data = mrow.parser.load_data(input)

    return target(data), data
end

return support
