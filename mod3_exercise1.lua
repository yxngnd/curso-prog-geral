local sampleNames = { "Maria", "Lucia", "Arthur", "Boris", "Newton" }
local testN = 10000
local users = {}

local function byName(a, b)
  return a.name < b.name
end

function registerUser(name)
  local lowerName = string.lower(name)
  local inf, sup = 1, #users
  while inf <= sup do
    local mid = math.floor((inf + sup) / 2)
    if lowerName < users[mid].name then
      sup = mid - 1
    else
      inf = mid + 1
    end
  end
  table.insert(users, inf, { id = #users, name = lowerName })
end

function registerUsers(names)
  for _, name in ipairs(names) do
    table.insert(users, { id = #users, name = string.lower(name) })
  end
  table.sort(users, byName)
end

function main()
  local names = {}
  local n = #sampleNames
  for i=1,testN do
    names[i] = sampleNames[((i-1) % n)+1]  .. i
  end

  registerUser('Fulano')
  registerUsers(names)
  registerUser('Beltrano')
  print('Users registered: ', #users)
end

main()
