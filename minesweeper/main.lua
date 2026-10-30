local helpers = require('helpers')
local const = require('const')

local function main()
  print('Welcome to Game Platform\n')

  local games = const.games
  if #games == 0 then
    print('No games available.')
    return
  end

  print('Which game do you want to play?')
  for i, gameConfig in ipairs(games) do
    print(i .. ' - ' .. gameConfig.name)
  end

  local gameId = helpers.readNumber('Choose the game: ', 1, #games, 'Invalid choice. Try again.')
  local gameConfig = games[gameId]

  local GameClass = require(gameConfig.filename)
  local game = GameClass.create(gameConfig)
  game:run()
end

main()
