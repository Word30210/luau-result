local Result = {}
local ResultPrototype = {
    __index = Result;
    __tostring = function<T, E>(self: Result<T, E>): string
        if self._ok then
			if type(self._v) == "string" then
				return string.format("Result::Ok(%q)", self._v)
			else
				return `Result::Ok({ self._v })`
			end
		end

		if type(self._e) == "string" then
			return string.format("Result::Err(%q)", self._e)
		else
			return `Result::Err({ self._e })`
		end
    end;
}
table.freeze(ResultPrototype)

export type Result<T, E> = setmetatable<{
    read _ok: boolean;
    read _v: T;
    read _e: E;
}, typeof(ResultPrototype)>

--- Checks if a value is a Result.
local function is(value: unknown): boolean
    return type(value) == "table" and getmetatable(value) == ResultPrototype
end

--- Constructs a new 'Ok' Result.
local function ok<T>(value: T): Result<T, unknown>
    return setmetatable(
        {
            _ok = true;
            _v = value;
            _e = nil :: any;
        },
        ResultPrototype
    )
end

--- Constructs a new 'Err' Result.
local function err<E>(error: E): Result<unknown, E>
    return setmetatable(
        {
            _ok = false;
            _v = nil :: any;
            _e = error;
        },
        ResultPrototype
    )
end

--- Calls the given function and returns a Result with the result of the function.
local function try<T, U...>(func: (U...) -> (T, ...any), ...: U...): Result<T, unknown>
    local is_ok, res = pcall(func, ...)

    if is_ok then
        return ok(res)
    else
        return err(res)
    end
end

--- Checks a value is 'Ok' Result.
function Result.is_ok<T, E>(self: Result<T, E>): boolean
    return self._ok
end

--- Checks a value is 'Err' Result.
function Result.is_err<T, E>(self: Result<T, E>): boolean
    return not self._ok
end

--- Returns the contained 'Ok'. Otherwise an error is thrown with the given message.
function Result.expect<T, E>(self: Result<T, E>, message: string): T
    if not self._ok then
        error(message, 2)
    end

    return self._v
end

--- Returns the contained 'Ok'. Otherwise the contained 'Err' value is thrown.
function Result.unwrap<T, E>(self: Result<T, E>): T
    if not self._ok then
        error(self._e, 2)
    end

    return self._v
end

--- Returns the contained 'Err'. Otherwise an error is thrown with the given message.
function Result.expect_err<T, E>(self: Result<T, E>, message: string): E
    if self._ok then
        error(message, 2)
    end

    return self._e
end

--- Returns the contained 'Err'. Otherwise the contained 'Ok' value is thrown.
function Result.unwrap_err<T, E>(self: Result<T, E>): E
    if self._ok then
        error(self._v, 2)
    end

    return self._e
end

--- Returns the contained `Ok` value, or the given default value.
function Result.unwrap_or<T, E, D>(self: Result<T, E>, default: D): T | D
    if self._ok then
        return self._v
    else
        return default
    end
end

--- Returns the contained 'Ok' value if the result is 'Ok'; Otherwise, returns nil.
function Result.some<T, E>(self: Result<T, E>): T?
    if self._ok then
        return self._v
    else
        return nil
    end
end

--- Returns a tuple where the first value is the contained `Ok` value or nil and the second value is the contained `Err` value or nil.
function Result.unpack<T, E>(self: Result<T, E>): (T, E)
    return self._v, self._e
end

--- Class Result
return {
    is = is;
    ok = ok;
    err = err;
    try = try;
}