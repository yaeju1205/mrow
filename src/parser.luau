const result = require("./result")

export type ParserData = {
    chars: { string },
    length: number,

    line_starts: { number },

    line: number,
    position: number,
}

export type ParserState = {
    line: number,
    position: number,
}

export type ParserError = {
    message: string,
    line: number,
    position: number,

    data: ParserData,

    format: (ParserError) -> string,
}

export type ParserErrors = {
    errors: { ParserError },

    format: (ParserErrors) -> string,
}

export type ParserResult<T...> = result.Result<ParserErrors, T...>

export type Parser<T...> = (ParserData) -> ParserResult<T...>

const parser = {}

function parser.load_data(input: string): ParserData
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
        length = input_length,

        line_starts = line_starts,

        line = 1,
        position = 1,
    }
end

function parser.save(data: ParserData): ParserState
    return {
        line = data.line,
        position = data.position,
    }
end

function parser.restore(data: ParserData, state: ParserState)
    data.line = state.line
    data.position = state.position
end

const function format_error(self: ParserError): string
    const data= self.data

    const line_start = data.line_starts[self.line]
    const line_end = data.line_starts[self.line + 1]
        and data.line_starts[self.line + 1] - 2
        or data.length

    const line_text = table.concat(self.data.chars, "", line_start, math.max(line_end, line_start - 1))
    const column = self.position - line_start + 1
    const gutter = string.rep(" ", #tostring(self.line))

    return table.concat({
        `{self.line}:{column}:`,
        `{gutter} |`,
        `{self.line} | {line_text}`,
        `{gutter} | {string.rep(" ", column - 1)}^`,
        self.message,
    }, "\n")
end

const function format_errors(self: ParserErrors): string
    const list = self.errors
    const blocks = table.create<<string>>(#list)

    for i = 1, #list do
        blocks[i] = list[i]:format()
    end

    return table.concat(blocks, "\n\n")
end

function parser.errors(errors: { ParserError }): ParserErrors
    return {
        errors = errors,

        format = format_errors,
    }
end

function parser.fail(data: ParserData, message: string): result.ResultFailed<ParserErrors>
    return result.failed(parser.errors({
        {
            message = message,
            line = data.line,
            position = data.position,

            data = data,

            format = format_error,
        }
    }))
end

function parser.peek(data: ParserData): ParserResult<string>
    if data.position > data.length then
        return parser.fail(data, "unexpected end of input")
    end

    return result.success(data.chars[data.position])
end

function parser.consume(data: ParserData): ParserResult<string>
    const char_result = parser.peek(data)
    if char_result.failed then
        return char_result
    end

    const char = char_result:unwrap()

    if char == "\n" then
       data.line += 1 
    end

    data.position += 1

    return result.success(char)
end

return parser
