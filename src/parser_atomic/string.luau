const parser = require("../parser")
const result = require("../result")

return function(expected: string): parser.Parser<string>
    const expected_length = utf8.len(expected) or 0

    return function(data: parser.ParserData): parser.ParserResult<string>
        const state = parser.save(data)
        local got = ""

        for i=1, expected_length do
            const char_result = parser.consume(data)
            if char_result.failed then
                parser.restore(data, state)

                return parser.fail(data, `expected '{expected}', got end of input`)
            end

            got ..= char_result:unwrap()

            if string.sub(expected, 1, #got) ~= got then
                parser.restore(data, state)

                return parser.fail(data, `expected '{expected}', got '{got}'`)
            end
        end

        return result.success(got)
    end
end
