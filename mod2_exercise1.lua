function setupRootElement()
  local root = {}
  root.id = 'rootElement'
  root.visible = true
  root.color = 'red'
  root['background color'] = 'yellow'
  root.text = 'Main Window'
  root.children = {
    { id = 'child1', zOrder = 1, visible = true, parent = root },
    { id = 'child2', zOrder = 2, visible = true, parent = root },
    { id = 'child3', zOrder = 3, visible = false, clickVolume = 0.02, parent = root },
  }
  root.savedIndexes = { 4, 1, 3, 2, 5, total = 5 }
  root.layoutPositions = { 'top', 'left', 'bottom', 'right' }
  root.innerLengths = { x = 1, l = { x = 2, l = { x = 3, l = { x = 4, l = { x = 5, l = { x = 6 } } } } } }

  return root
end

local function formatValue(v)
  if type(v) == 'number' or type(v) == 'boolean' then
    return tostring(v)
  end
  return string.format('%q', tostring(v))
end

local function formatKey(k)
  if type(k) == 'string' and k:match('^[%a_][%w_]*$') then
    return k .. ' = '
  end
  return '[' .. formatValue(k) .. '] = '
end

function table.tostring(t, maxDepth, indent)
  local seen = {}
  local buffer = {}

  local function add(text)
    buffer[#buffer + 1] = text
  end

  local function writeValue(value, depth)
    if type(value) ~= 'table' or seen[value] or depth > maxDepth then
      add(formatValue(value))
      return
    end
    seen[value] = true

    local indentation = string.rep(indent, depth)
    add('{\n')

    local arraySize = 0
    for i, item in ipairs(value) do
      arraySize = i
      add(indentation)
      writeValue(item, depth + 1)
      add(',\n')
    end

    for key, item in pairs(value) do
      local isArrayIndex = type(key) == 'number' and key >= 1 and key <= arraySize and key % 1 == 0
      if not isArrayIndex then
        add(indentation .. formatKey(key))
        writeValue(item, depth + 1)
        add(',\n')
      end
    end

    add(string.rep(indent, depth - 1) .. '}')
  end

  writeValue(t, 1)
  return table.concat(buffer)
end

function main()
  local rootElement = setupRootElement()
  local s = table.tostring(rootElement, 3, '  ')

  print(s)
  local f, err = loadstring('return ' .. s)
  if f then
    print('Tabela valida!')
  else
    print('Erro de sintaxe: ' .. err)
  end
end

main()
