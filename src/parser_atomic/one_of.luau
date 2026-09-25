const parser = require("../parser")
const satisfy = require("./satisfy")

--[=[
    @tag atomic
    @param chars string -- The allowed characters, written as one string
    @return Parser<string>

    Builds a parser that consumes one character out of `chars`.

    ```luau
    const digit = mrow.one_of("0123456789")
    mrow.parse("7", digit):unwrap() --> "7"
    mrow.parse("x", digit).failed --> true
    ```
]=]
return function(chars: string): parser.Parser<string>
    const allowed: { [string]: true } = {}

    for _, code in utf8.codes(chars) do
        allowed[utf8.char(code)] = true
    end

    return satisfy(`one of '{chars}'`, function(char: string): boolean
        return allowed[char] ~= nil
    end)
end
