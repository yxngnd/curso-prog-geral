local Board = require('board')
local helpers = require('helpers')
local Minesweeper = {}

function Minesweeper.create(config)
  local ms = {}
  ms.config = config
  ms.symbols = config.symbols

  setmetatable(ms, {
    __index = Minesweeper
  })
  return ms
end

function Minesweeper:run()
  print('Minesweeper is starting...')

  local difficulty, cheat = self:selectDifficulty()
  self:setupGame(difficulty)
  if cheat then
    print('Cheat enabled!')
  end

  while self.gameRunning do
    self:displayGame()

    local action, row, column
    if cheat then
      action, row, column = self:chooseCheatMove()
      local verb = action == 'f' and 'flagging' or 'opening'
      print('Cheat: ' .. verb .. ' ' .. helpers.formatCoordinate(row, column))
      helpers.sleep(self.config.cheatDelay)
    else
      action, row, column = self:readMove()
    end

    if action == 'f' then
      self:toggleFlag(row, column)
    else
      self:openCell(row, column)
    end

    if self.gameRunning and self:checkVictory() then
      self.gameRunning = false
      self.won = true
    end
  end

  self:showResult()
  print('Minesweeper has finished!')
end

function Minesweeper:selectDifficulty()
  print('Choose the difficulty:')
  local difficulties = self.config.difficulties
  local index, cheat = helpers.readOption('Difficulty: ', difficulties,
    'Invalid choice. Try again.', self.config.cheatSuffix)
  return difficulties[index], cheat
end

function Minesweeper:setupGame(difficulty)
  self.rows = difficulty.rows
  self.columns = difficulty.columns
  self.totalMines = difficulty.mines

  self.board = Board.create(self.rows, self.columns, self.symbols.hidden, true)
  self.mines = Board.create(self.rows, self.columns, false)

  self.minesPlaced = false
  self.flags = 0
  self.openedCells = 0
  self.gameRunning = true
  self.won = false
  self.startTime = os.time()
end

function Minesweeper:readMove()
  while true do
    io.write('Move (o A1 = open, f A1 = flag): ')
    local input = io.read()
    if not input then os.exit() end

    local action, coordinate = input:lower():match('^%s*([of])%s*(%a%d+)%s*$')
    if action then
      local row, columnOrError = helpers.parseCoordinate(coordinate, self.rows, self.columns)
      if row then
        return action, row, columnOrError
      end
      print(columnOrError)
    else
      print('Invalid move. Use o or f followed by a coordinate, e.g. o A1.')
    end
  end
end

function Minesweeper:getNeighbors(row, column)
  local neighbors = {}
  for i = row - 1, row + 1 do
    for j = column - 1, column + 1 do
      local inside = i >= 1 and i <= self.rows and j >= 1 and j <= self.columns
      if inside and (i ~= row or j ~= column) then
        table.insert(neighbors, { i, j })
      end
    end
  end
  return neighbors
end

function Minesweeper:countMinesAround(row, column)
  local count = 0
  for _, cell in ipairs(self:getNeighbors(row, column)) do
    if self.mines:getValue(cell[1], cell[2]) then
      count = count + 1
    end
  end
  return count
end

function Minesweeper:placeMines(safeRow, safeColumn)
  local candidates = {}
  for i = 1, self.rows do
    for j = 1, self.columns do
      if math.abs(i - safeRow) > 1 or math.abs(j - safeColumn) > 1 then
        table.insert(candidates, { i, j })
      end
    end
  end

  for i = 1, self.totalMines do
    local k = math.random(i, #candidates)
    candidates[i], candidates[k] = candidates[k], candidates[i]
    self.mines:setValue(candidates[i][1], candidates[i][2], true)
  end
  self.minesPlaced = true
end

function Minesweeper:openCell(row, column)
  local value = self.board:getValue(row, column)
  if value == self.symbols.flag then
    print('Remove the flag before opening this cell.')
    return
  elseif value ~= self.symbols.hidden then
    print('This cell is already open.')
    return
  end

  if not self.minesPlaced then
    self:placeMines(row, column)
  end

  if self.mines:getValue(row, column) then
    self.gameRunning = false
    return
  end

  local stack = { { row, column } }
  while #stack > 0 do
    local cell = table.remove(stack)
    local i, j = cell[1], cell[2]

    if self.board:getValue(i, j) == self.symbols.hidden then
      local count = self:countMinesAround(i, j)
      self.openedCells = self.openedCells + 1

      if count > 0 then
        self.board:setValue(i, j, tostring(count))
      else
        self.board:setValue(i, j, self.symbols.empty)
        for _, neighbor in ipairs(self:getNeighbors(i, j)) do
          table.insert(stack, neighbor)
        end
      end
    end
  end
end

function Minesweeper:toggleFlag(row, column)
  local value = self.board:getValue(row, column)
  if value == self.symbols.hidden then
    self.board:setValue(row, column, self.symbols.flag)
    self.flags = self.flags + 1
  elseif value == self.symbols.flag then
    self.board:setValue(row, column, self.symbols.hidden)
    self.flags = self.flags - 1
  else
    print('You cannot flag an open cell.')
  end
end

function Minesweeper:checkVictory()
  return self.openedCells == self.rows * self.columns - self.totalMines
end

function Minesweeper:chooseCheatMove()
  if not self.minesPlaced then
    return 'o', math.random(self.rows), math.random(self.columns)
  end

  local candidates = self:getCheatCandidates(false)
  if #candidates == 0 then
    candidates = self:getCheatCandidates(true)
  end

  local cell = candidates[math.random(#candidates)]
  local action = self.mines:getValue(cell[1], cell[2]) and 'f' or 'o'
  return action, cell[1], cell[2]
end

function Minesweeper:getCheatCandidates(flagsCountAsExplored)
  local hidden = self.symbols.hidden
  local flag = self.symbols.flag
  local candidates = {}

  for i = 1, self.rows do
    for j = 1, self.columns do
      if self.board:getValue(i, j) == hidden then
        for _, neighbor in ipairs(self:getNeighbors(i, j)) do
          local value = self.board:getValue(neighbor[1], neighbor[2])
          if value ~= hidden and (flagsCountAsExplored or value ~= flag) then
            table.insert(candidates, { i, j })
            break
          end
        end
      end
    end
  end
  return candidates
end

function Minesweeper:displayGame()
  local elapsed = os.time() - self.startTime
  print(string.format('Time: %02d:%02d | Flags: %d | Mines: %d',
    math.floor(elapsed / 60), elapsed % 60, self.flags, self.totalMines))
  self.board:draw()
end

function Minesweeper:showResult()
  local symbol = self.won and self.symbols.flag or self.symbols.mine
  for i = 1,self.rows do
    for j = 1,self.columns do
      if self.mines:getValue(i, j) and self.board:getValue(i, j) == self.symbols.hidden then
        self.board:setValue(i, j, symbol)
        if self.won then
          self.flags = self.flags + 1
        end
      end
    end
  end

  self:displayGame()
  if self.won then
    print('Congratulations, you won!')
  else
    print('BOOM! You hit a mine.')
  end
end

return Minesweeper
