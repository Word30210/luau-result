local frktest = require("@lune_pkg/frktest")
local Result = require("../src/lib")

local test = frktest.test
local check = frktest.assert.check

return function()
    test.suite("Result Module", function()
        
        test.case("Constructors (ok, err, is)", function()
            local ok_res = Result.ok("success")
            local err_res = Result.err("failure")

            check.equal(Result.is(ok_res), true)
            check.equal(Result.is(err_res), true)
            check.equal(Result.is({}), false)
            
            check.equal(ok_res:is_ok(), true)
            check.equal(err_res:is_err(), true)
            
            return nil
        end)

        test.case("Result.try functional wrapper", function()
            local success_try = Result.try(function(a: number, b: number)
                return (a + b) :: any
            end, 10, 20)
            
            check.equal(success_try:is_ok(), true)
            check.equal(success_try:unwrap(), 30)

            local fail_try = Result.try(function()
                error("oops")
            end)

            check.equal(fail_try:is_err(), true)
            check.equal(type(fail_try:unwrap_err()), "string")
            
            return nil
        end)

        test.case("Unwrapping 'Ok' values", function()
            local res = Result.ok(100)

            check.equal(res:unwrap(), 100)
            check.equal(res:expect("Should be 100"), 100)
            check.equal(res:unwrap_or(0), 100)
            check.equal(res:some(), 100)
            
            check.should_error(function()
                res:unwrap_err()

                return nil
            end)

            return nil
        end)

        test.case("Unwrapping 'Err' values", function()
            local res = Result.err("error_message")

            check.equal(res:unwrap_err(), "error_message")
            check.equal(res:expect_err("Should be error"), "error_message")
            check.equal(res:unwrap_or(50), 50)
            check.equal(res:some(), nil)
            
            check.should_error(function()
                res:unwrap()

                return nil
            end)

            return nil
        end)

        test.case("Utility methods (unpack, tostring)", function()
            local val, e = "data", "no_error"
            
            -- Ok unpack
            local ok_res = Result.ok(val)
            local v1, e1 = ok_res:unpack()
            check.equal(v1, val)
            check.equal(e1, nil)

            -- Err unpack
            local err_res = Result.err(e)
            local v2, e2 = err_res:unpack()
            check.equal(v2, nil)
            check.equal(e2, e)

            check.equal(tostring(ok_res), 'Result::Ok("data")')
            check.equal(tostring(err_res), 'Result::Err("no_error")')
            
            check.equal(tostring(Result.ok(123)), 'Result::Ok(123)')

            return nil
        end)

        return nil
    end)
end