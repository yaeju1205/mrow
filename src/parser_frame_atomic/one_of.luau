const parser = require("../parser")
const satisfy = require("./satisfy")

--[=[
    @tag atomic
    @param chars string -- The allowed characters, written as one string
    @return ParserFrame

    Builds a parser that consumes one character out of `chars`.

    ```luau
    const digit = mrow.one_of("0123456789")
    mrow.create(digit)("7").value --> "7"
    mrow.create(digit)("x").success --> false
    ```
]=]
return function(chars: string): parser.ParserFrame
    const allowed: { [string]: true } = {}

    for _, code in utf8.codes(chars) do
        allowed[utf8.char(code)] = true
    end

    return satisfy(`one of '{chars}'`, function(char: string): boolean
        return allowed[char] ~= nil
    end)
end
