local Board = {}

function Board.create(rows, columns, defaultValue, letterRows)
  assert(not letterRows or rows <= 26, 'Letter rows support at most 26 rows.')

  local board = {}
  board.rows = rows
  board.columns = columns
  board.data = {}

  for i = 1, rows do
    board.data[i] = {}
    for j = 1, columns do
      board.data[i][j] = defaultValue
    end
  end

  board.cellFormat = ' %' .. #tostring(columns) .. 's'
  local labelWidth = letterRows and 1 or #tostring(rows)
  board.rowLabels = {}
  for i = 1, rows do
    local label = letterRows and string.char(64 + i) or i
    board.rowLabels[i] = string.format('%' .. labelWidth .. 's', label)
  end

  local header = { string.rep(' ', labelWidth) }
  for j = 1, columns do
    header[j + 1] = string.format(board.cellFormat, j)
  end
  board.header = table.concat(header)

  setmetatable(board, {
    __index = Board
  })
  return board
end

function Board:draw()
  local lines = { self.header }
  local line = {}

  for i = 1, self.rows do
    local row = self.data[i]
    line[1] = self.rowLabels[i]
    for j = 1,self.columns do
      line[j + 1] = string.format(self.cellFormat, row[j])
    end
    lines[i + 1] = table.concat(line)
  end

  lines[#lines + 1] = ''
  print(table.concat(lines, '\n'))
end

function Board:setValue(row, column, value)
  self.data[row][column] = value
end

function Board:getValue(row, column)
  return self.data[row][column]
end

return Board
