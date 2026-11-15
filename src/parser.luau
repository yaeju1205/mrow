const parser = {}

export type ParserFrame = (ParserContext) -> ()

export type ParserContext = {
    source: string,
    length: number,
    offset: number,
    stack_callee: { ParserFrame },
    stack_top: number,
    stack_value: { any },
    stack_value_top: number,
    running: { [ParserFrame]: { [number]: any } },
    return_value: any,
    return_error: any,
}

function parser.context(source: string): ParserContext?
    if not utf8.len(source) then
        return nil
    end

    return {
        source = source,
        length = #source,
        offset = 1,
        stack_callee = {},
        stack_top = 0,
        stack_value = {},
        stack_value_top = 0,
        running = {},
        return_value = nil,
        return_error = nil,
    }
end

function parser.peek(context: ParserContext): string?
    const offset = context.offset
    const next_offset = utf8.offset(context.source, 2, offset)
    if not next_offset then
        return nil
    end

    return string.sub(context.source, offset, next_offset - 1)
end

function parser.next(context: ParserContext): string?
    const char = parser.peek(context)

    if char then
        context.offset += #char
    end

    return char
end

function parser.stack_frame_push(context: ParserContext, frame: ParserFrame)
    const top = context.stack_top + 1

    context.stack_top = top
    context.stack_callee[top] = frame
end

parser.stack_value_nil = table.freeze({})

function parser.stack_value_push(context: ParserContext, value: any)
    const top = context.stack_value_top + 1

    context.stack_value_top = top

    if value == nil then
        context.stack_value[top] = parser.stack_value_nil
    else
        context.stack_value[top] = value
    end
end

function parser.stack_value_pop(context: ParserContext): any
    const top = context.stack_value_top
    const stack_value = context.stack_value
    const value = stack_value[top]

    stack_value[top] = nil
    context.stack_value_top = top - 1

    if value == parser.stack_value_nil then
        return nil
    end

    return value
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
    return function(source: string): ParserSuccess<T> | ParserFailed
        const context = parser.context(source)

        if not context then
            return {
                success = false,
                error = `expected source, but got {source}`,
            }
        end

        const stack_callee = context.stack_callee
        parser.stack_frame_push(context, frame)

        while true do
            const top = context.stack_top

            if top == 0 then
                break
            end

            const frame = stack_callee[top]
            stack_callee[top] = nil
            context.stack_top = top - 1

            frame(context)
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
