const parser = require("./parser")

--[=[
    @class trampoline

    Runs a grammar without growing the Lua call stack with its nesting. Luau caps the
    calls one thread can stack (about 20,000), so a recursive grammar that calls
    itself directly overflows on deeply nested input.

    A parser either returns its result, or asks for a child to run first by returning
    `CALL, child, continue`; [trampoline.run] then keeps `continue` on a table stack,
    runs `child`, and hands its result to `continue`.

    Parsers that can never recurse are marked with [trampoline.leaf] and are simply
    called. A combinator whose parsers are all leaves is a leaf itself and runs as
    plain calls; only the paths that go through [mrow.lazy] pay for the trampoline.
]=]
const trampoline = {}

trampoline.CALL = table.freeze({})

const leaves: { [any]: true } = setmetatable({}, { __mode = "k" }) :: any

--[=[
    Marks `target` as a parser that returns its result directly and never recurses.
]=]
function trampoline.leaf<F>(target: F): F
    leaves[target] = true

    return target
end

function trampoline.is_leaves(...: any): boolean
    for i = 1, select("#", ...) do
        if not leaves[(select(i, ...))] then
            return false
        end
    end

    return true
end

--[=[
    Runs `child` and hands its result to `continue`: directly when `child` is a leaf,
    through [trampoline.run] otherwise.
]=]
function trampoline.step(child: any, data: parser.ParserData, continue: (any) -> ...any): ...any
    if leaves[child] then
        return continue(child(data))
    end

    return trampoline.CALL, child, continue
end

--[=[
    Runs `target` to its final result. Use it to call a parser from outside a grammar,
    or from a hand-written parser that needs another parser's result.
]=]
function trampoline.run<T...>(target: parser.Parser<T...>, data: parser.ParserData): parser.ParserResult<T...>
    const CALL = trampoline.CALL
    const stack: { (any) -> ...any } = {}
    local top = 0

    local step: any, child: any, continue: any = (target :: any)(data)
    while true do
        if step == CALL then
            top += 1
            stack[top] = continue
            step, child, continue = child(data)
        else
            if top == 0 then
                return step
            end

            const resume = stack[top]
            stack[top] = nil
            top -= 1
            step, child, continue = resume(step)
        end
    end
end

return trampoline
