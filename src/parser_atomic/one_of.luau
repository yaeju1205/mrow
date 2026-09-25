const parser = require("../parser")
const satisfy = require("./satisfy")

return function(chars: string): parser.Parser<string>
    const allowed: { [string]: true } = {}

    for _, code in utf8.codes(chars) do
        allowed[utf8.char(code)] = true
    end

    return satisfy(`one of '{chars}'`, function(char: string): boolean
        return allowed[char] ~= nil
    end)
end
