const parser_data = require("./parser_data")
const parser_store = require("./parser_store")

export type ParserError = {
    message: string,
    position: parser_data.ParserPosition,
    data: parser_data.ParserData,
}

export type ParserSuccess<T...> = {
    failed: false,
    packed: { n: number, [number]: any },

    unwrap: (ParserSuccess<T...>) -> T...
}

export type ParserFailed = {
    failed: true,
    errors: { ParserError },
    format: (ParserFailed) -> string,
}

export type ParserResult<T...> =  | ParserFailed | ParserSuccess<T...>

const parser_result = {}

function parser_result.unwrap<T...>(success: ParserSuccess<T...>): T...
    return table.unpack(success.packed, 1, success.packed.n)
end

function parser_result.success<T...>(...: T...): ParserSuccess<T...>
    const args = table.pack<<any>>(...)

    return {
        failed = false,
        packed = args,

        unwrap = parser_result.unwrap
    }
end

function parser_result.format(failed: ParserFailed): string
    return "TODO: make format"
end

function parser_result.fail(data: parser_data.ParserData, ...: string): ParserFailed
    const messages = { ... }
    const errors: { ParserError } = {}

    for i=1, #messages do
        const message = messages[i]

        errors[i] = {
            message = message,
            position = parser_store.store(data),
            data = data,
        }
    end

    return {
        failed = true,
        errors = errors,
        format =parser_result.format
    }
end

return parser_result