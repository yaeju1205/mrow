export type ParserPosition = {
    line: number,
    column: number,
}

export type ParserData = {
    chars: { string },
    chars_length: number,
    char_index: number,

    position: ParserPosition,

    line_starts: { number },
}

const parser_data = {}

function parser_data.load_data(input: string): ParserData
    const input_length = utf8.len(input) or 0

    const chars: { [number]: string } = table.create<<string>>(input_length)
    const line_starts = { 1 }

    local index = 1
    for _, code in utf8.codes(input) do
        chars[index] = utf8.char(code)
        index += 1

        if code == 10 then
            table.insert(line_starts, index)
        end
    end

    return {
        chars = chars,
        chars_length = input_length,
        char_index = 1,

        position = {
            line = 1,
            column = 1,
        },

        line_starts = line_starts,
    }
end

return parser_data