#!/usr/bin/env lua

local args = {}
local queries = {}
local skip = false

for i=1, #arg do
  local value = arg[i]
  local match = value:match('^%-%-(.+)$') 
  if skip then
    skip = false
  elseif value == '--no-dotfiles' then
    -- do nothing
  elseif match then
    args[match] = arg[i + 1]
    skip = true
  else
    queries[#queries + 1] = value
  end
end

local patterns = {}

for _, query in ipairs(queries) do
  for q in (query or ''):gmatch('%S+') do
    patterns[#patterns+1] = {
      '^'  .. q,
      '%p' .. q
    }
  end
end

local count = 0
local limit = args.limit and tonumber(args.limit) or 50
local manifest = args.manifest and io.open(args.manifest) or io.stdin

local function matches_any(line, patterns)
  for _, sub in ipairs(patterns) do
    if line:find(sub) then
      return true
    end
  end
end

local function matches_all_patterns(line)
  for _, pattern in ipairs(patterns) do
    if not matches_any(line, pattern) then
      return false
    end
  end

  return true
end

for line in manifest:lines() do
  if matches_all_patterns(line) then
    count = count + 1
    print(line)

    if limit == count then break end
  end
end

