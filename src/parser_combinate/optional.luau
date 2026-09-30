const parser = require("../parser")

--[=[
    @tag combinator
    @param item Parser<T>
    @return Parser<T?>

    Turns a failure of `item` into a success holding `nil`, so a piece of syntax may
    simply be absent. Every parser in this library rewinds itself when it fails, so a
    missing match leaves the position untouched.

    ```luau
    const sign = mrow.optional(mrow.string("-"))
    mrow.parse_partial("-1", sign):unwrap() --> "-"
    mrow.parse_partial("1", sign):unwrap() --> nil
    ```
]=]
return function<T>(item: parser.Parser<T>): parser.Parser<T?>
    return function(data: parser.ParserData): parser.ParserResult<T?>
        const parsed = item(data)
        if parsed.failed then
            return parser.success(nil)
        end

        return parser.success(parsed:unwrap())
    end
end
