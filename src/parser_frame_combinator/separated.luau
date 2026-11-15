const parser = require("../parser")

--[=[
    @tag combinator
    @param item ParserFrame
    @param separator ParserFrame -- Matched between items, its value is dropped
    @return ParserFrame -- Produces a table of the items

    Parses `item` repeatedly, with `separator` in between, and collects the items.
    Never fails: an empty list is a success holding an empty table. A separator with
    no item behind it is left unconsumed, so a trailing comma stays for the parser
    that comes next to complain about.

    ```luau
    const list = mrow.separated(mrow.integer, mrow.string(","))
    mrow.create(list)("1,2,3").value --> { 1, 2, 3 }
    mrow.create(list)("").value --> {}
    ```
]=]
return function(item: parser.ParserFrame, separator: parser.ParserFrame): parser.ParserFrame
    -- Value stack: the values so far, how many there are, and where the last separator
    -- started. A failed item rewinds to that separator, and an item and separator that
    -- consumed nothing together end the list.
    local after_item: parser.ParserFrame

    const function push_state(context: parser.ParserContext, values: { any }, count: number, before: number)
        parser.stack_value_push(context, values)
        parser.stack_value_push(context, count)
        parser.stack_value_push(context, before)
    end

    const function after_separator(context: parser.ParserContext)
        const before: number = parser.stack_value_pop(context)
        const count: number = parser.stack_value_pop(context)
        const values: { any } = parser.stack_value_pop(context)

        if context.return_error then
            context.return_error = nil
            context.offset = before
            context.return_value = values
            return
        end

        push_state(context, values, count, before)
        parser.stack_frame_push(context, after_item)
        parser.stack_frame_push(context, item)
    end

    after_item = function(context: parser.ParserContext)
        const before: number = parser.stack_value_pop(context)
        local count: number = parser.stack_value_pop(context)
        const values: { any } = parser.stack_value_pop(context)

        if context.return_error then
            context.return_error = nil
            context.offset = before
            context.return_value = values
            return
        end

        count += 1
        values[count] = context.return_value

        if context.offset == before then
            context.return_value = values
            return
        end

        push_state(context, values, count, context.offset)
        parser.stack_frame_push(context, after_separator)
        parser.stack_frame_push(context, separator)
    end

    const function after_first(context: parser.ParserContext)
        const values: { any } = {}

        if context.return_error then
            context.return_error = nil
            context.return_value = values
            return
        end

        values[1] = context.return_value

        push_state(context, values, 1, context.offset)
        parser.stack_frame_push(context, after_separator)
        parser.stack_frame_push(context, separator)
    end

    return function(context: parser.ParserContext)
        parser.stack_frame_push(context, after_first)
        parser.stack_frame_push(context, item)
    end
end
