const parser = require("../parser")
const satisfy = require("./satisfy")

return function(chars: string): parser.Parser<string>
    const forbidden: { [string]: true } = {}

    for _, code in utf8.codes(chars) do
        forbidden[utf8.char(code)] = true
    end

    return satisfy(`none of '{chars}'`, function(char: string): boolean
        return forbidden[char] == nil
    end)
end
