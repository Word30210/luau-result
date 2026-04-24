local fs = require("@lune/fs")
local frktest = require("@lune_pkg/frktest")
local console_reporter = frktest._reporters.lune_console_reporter

local success, flie_paths = pcall(fs.readDir, "test")

if not success then
    error("tests are missing. Make sure you run this from the project root directory.")
end

for _, file_path in next, flie_paths do
    local luau_file_path = string.match(file_path, "(.-).luau$")

    if not luau_file_path then
        continue
    end

    if string.find(luau_file_path, "^run$") then
        continue
    end

    (require :: any)(`./{ luau_file_path }`)()
end

console_reporter.init()
frktest.run()

return nil