const parser = {}

export type ParserFrame = (ParserContext) -> ()

export type ParserContext = {
    source: string,
    chars: { [number]: string },
    chars_length: number,
    line: number,
    column: number,
    offset: number,
    stack_callee: { [number]: ParserFrame },
    stack_top: number,
    return_from: ParserFrame?,
    return_value: any,
    return_error: any,
}

function parser.context(source: string): ParserContext?
    const input_length = utf8.len(source)
    if not input_length then
        return
    end

    const chars = table.create<<string>>(input_length)

    local index = 1
    for _, code in utf8.codes(source) do
        chars[index] = utf8.char(code)
        index += 1
    end

    return {
        source = source,
        chars = chars,
        chars_length = #chars,
        line = 1,
        column = 1,
        offset = 1,
        stack_callee = {},
        stack_caller = {},
        stack_top = 1,
        return_from = nil,
        return_value = nil,
        return_error = nil,
    }
end

function parser.peek(context: ParserContext): string?
    return context.chars[context.offset]
end

function parser.next(context: ParserContext): string?
    const peeked_char = parser.peek(context)

    if not peeked_char then
        return
    end

    context.offset += 1

    if peeked_char == "\n" then
        context.column = 1
        context.line += 1
    else
        context.column += 1
    end

    return peeked_char
end

function parser.stack_frame_push(context: ParserContext, frame: ParserFrame)
    const top = context.stack_top + 1

    context.stack_top = top
    context.stack_callee[top] = frame
end

function parser.stack_frame_pop(context: ParserContext): ParserFrame?
    const top = context.stack_top

    if top == 0 then
        return nil
    end

    const frame = context.stack_callee[top]

    context.stack_callee[top] = nil
    context.stack_top = top - 1

    return frame
end

export type ParserSnapshot = {
    offset: number,
    line: number,
    column: number,
    stack_top: number,
}

function parser.snapshot_save(context: ParserContext): ParserSnapshot
    return {
        offset = context.offset,
        line = context.line,
        column = context.column,
        stack_top = context.stack_top,
    }
end

function parser.snapshot_restore(context: ParserContext, snapshot: ParserSnapshot)
    context.offset = snapshot.offset
    context.line = snapshot.line
    context.column = snapshot.column
    context.stack_top = snapshot.stack_top
end

export type ParserFailed = {
    success: false,
    error: string,
}

export type ParserSuccess<T> = {
    success: true,
    value: T,
}

export type Parser<T> = (string) -> ParserFailed | ParserSuccess<T>

function parser.create<T>(frame: ParserFrame): Parser<T>
    return function(source: string)
        const context = parser.context(source)

        if not context then
            return {
                success = false,
                error = `expected source, but got {source}`,
            }
        end

        context.stack_callee[1] = frame

        while true do
            const frame = parser.stack_frame_pop(context)

            if not frame then
                break
            end

            frame(context)
            context.return_from = frame
        end

        if context.return_error then
            return {
                success = false,
                error = context.return_error,
            }
        end

        return {
            success = true,
            value = context.return_value,
        }
    end
end

return parser
