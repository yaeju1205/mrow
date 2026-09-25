export type ResultSuccess<T...> = {
    failed: false,

    packed: { n: number, [number]: any },

    unwrap: (ResultSuccess<T...>) -> T...
}

export type ResultFailed<E> = {
    failed: true,
    error: E,
}

export type Result<E, T...> =  | ResultFailed<E> | ResultSuccess<T...>

const result = {}

const function unwrap<T...>(success: ResultSuccess<T...>): T...
    return table.unpack(success.packed, 1, success.packed.n)
end

function result.success<T...>(...: T...): ResultSuccess<T...>
    const args = table.pack<<any>>(...)

    return {
        failed = false,
        packed = args,

        unwrap = unwrap
    }
end

function result.failed<E>(error: E): ResultFailed<E>
    return {
        failed = true,
        error = error,
    }
end

return result
