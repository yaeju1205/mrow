const parser_data = require("./parser_data")

const parser_store = {}

function parser_store.store(data: parser_data.ParserData): parser_data.ParserPosition
    return table.clone(data.position)
end

function parser_store.restore(data: parser_data.ParserData, position: parser_data.ParserPosition)
    data.position.column = position.column
    data.position.line = position.line
    data.char_index = data.line_starts[position.line] + position.column - 1
end

return parser_store