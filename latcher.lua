#!/usr/bin/env lua

args = {}
queries = {}
argname = nil

for i, value in ipairs(arg) do
  if value == '--no-dotfiles' then
    -- do nothing
  elseif argname then
    args[argname] = value
    argname = nil
  else
    match = string.match(value, '^%-%-(.+)$')
    if match then
      argname = match
    else
      table.insert(queries, value)
    end
  end
end

patterns = {}

for i, query in ipairs(queries) do
  for q in string.gmatch(query or '', '%S+') do
    sub = {}
    table.insert(patterns, sub)
    table.insert(sub, '^'..q)
    table.insert(sub, '%p'..q)
  end
end

count = 0
args.limit = args.limit and tonumber(args.limit) or 50

if args.manifest then
  manifest = io.open(args.manifest)
else
  manifest = io.stdin
end

for line in manifest:lines() do
  matched = true

  for i, sub in ipairs(patterns) do
    submatched = false

    for j, pattern in ipairs(sub) do
      if string.find(line, pattern) then
        submatched = true
      end
    end

    if not submatched then matched = false end
  end

  if matched then
    count = count + 1
    print(line)

    if args.limit == count then break end
  end
end

