local ffi = require('ffi')
local helpers = {}
local IS_WINDOWS = ffi.os == 'Windows'

if IS_WINDOWS then
  pcall(ffi.cdef, 'void Sleep(unsigned int ms);')
else
  pcall(ffi.cdef, 'int poll(void *fds, unsigned long nfds, int timeout);')
end

math.randomseed(os.time())

function helpers.readNumber(message, min, max, err)
  local number
  while not number do
    io.write(message)
    number = tonumber(io.read())
    if not number or number % 1 ~= 0 or number < min or number > max then
      print(err)
      number = nil
    end
  end
  return number
end

function helpers.readOption(message, options, err, suffix)
  for i, option in ipairs(options) do
    print(i .. ' - ' .. option.name)
  end

  while true do
    io.write(message)
    local input = io.read()
    if not input then os.exit() end

    local cheat = input:sub(-#suffix) == suffix
    if cheat then
      input = input:sub(1, -#suffix - 1)
    end

    local index = tonumber(input)
    if index and index % 1 == 0 and index >= 1 and index <= #options then
      return index, cheat
    end
    print(err)
  end
end

local FIRST_LETTER_CODE = string.byte('A')

function helpers.parseCoordinate(text, rows, columns)
  local letter, digits = text:upper():match('^%s*([A-Z])(%d+)%s*$')
  if not letter then
    return nil, 'Invalid format. Use a letter + number combination, e.g. A1.'
  end

  local row = letter:byte() - FIRST_LETTER_CODE + 1
  local column = tonumber(digits)

  if row > rows then
    return nil, "Row '" .. letter .. "' is outside the board."
  end
  if column < 1 or column > columns then
    return nil, 'Column must be between 1 and ' .. columns .. '.'
  end
  return row, column
end

function helpers.formatCoordinate(row, column)
  return string.char(FIRST_LETTER_CODE + row - 1) .. column
end

function helpers.sleep(seconds)
  local ms = math.floor(seconds * 1000)
  if IS_WINDOWS then
    ffi.C.Sleep(ms)
  else
    ffi.C.poll(nil, 0, ms)
  end
end

return helpers
