const parser = require("../parser")
const satisfy = require("./satisfy")

--[=[
    @tag atomic
    @param chars string -- The forbidden characters, written as one string
    @return Parser<string>

    Builds a parser that consumes one character, as long as it is not one of `chars`.
    The mirror of [mrow.one_of].

    ```luau
    const text_char = mrow.none_of("\"\\")
    mrow.parse("a", text_char):unwrap() --> "a"
    mrow.parse("\"", text_char).failed --> true
    ```
]=]
return function(chars: string): parser.Parser<string>
    const forbidden: { [string]: true } = {}

    for _, code in utf8.codes(chars) do
        forbidden[utf8.char(code)] = true
    end

    return satisfy(`none of '{chars}'`, function(char: string): boolean
        return forbidden[char] == nil
    end)
end
