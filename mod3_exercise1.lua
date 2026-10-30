local sampleNames = { "Maria", "Lucia", "Arthur", "Boris", "Newton" }
local testN = 10000
local users = {}

function registerUser(name)
  local lowerName = string.lower(name)
  table.insert(users, { id = #users, name = lowerName })
  table.sort(users, function(a, b) return a.name < b.name end)
end

function registerUsers(names)
  for _,name in ipairs(names) do
    registerUser(name)
  end
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
