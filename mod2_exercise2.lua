local craftRecipes = {
  {
    name = 'chair',
    ingredients = {
      { name = 'wood', count = 4 },
      { name = 'paint', count = 1 },
      { name = 'nail', count = 4 },
    },
  },
  {
    name = 'table',
    ingredients = {
      { name = 'wood', count = 8 },
      { name = 'paint', count = 1 },
      { name = 'nail', count = 4 },
    },
  },
  {
    name = 'halloween costume',
    ingredients = {
      { name = 'pumpkin', count = 1 },
      { name = 'cloth', count = 8 },
    },
  },
  {
    name = 'stone axe',
    ingredients = {
      { name = 'wood', count = 2 },
      { name = 'stone', count = 2 },
    },
  },
}

local craftsByIngredient = {}

function setupCraftsByIngredient()
  craftsByIngredient = {}
  for _, recipe in ipairs(craftRecipes) do
    local seen = {}
    for _, ingredient in ipairs(recipe.ingredients) do
      local name = ingredient.name
      if not seen[name] then
        seen[name] = true
        local list = craftsByIngredient[name]
        if not list then
          list = {}
          craftsByIngredient[name] = list
        end
        list[#list + 1] = recipe
      end
    end
  end
end

function getRecipes()
  return craftRecipes
end

function getRecipesByIngredientName(name)
  if type(name) ~= 'string' then
    return {}
  end
  return craftsByIngredient[name] or {}
end

function getAvailableRecipes(ingredients)
  local inventory, distinct = {}, 0
  for _, item in ipairs(ingredients or {}) do
    local name, count = item.name, item.count
    if type(name) == 'string' and type(count) == 'number' and count > 0 then
      if not inventory[name] then
        distinct = distinct + 1
      end
      inventory[name] = (inventory[name] or 0) + count
    end
  end

  local result, checked = {}, {}
  for name in pairs(inventory) do
    for _, recipe in ipairs(craftsByIngredient[name] or {}) do
      if not checked[recipe] then
        checked[recipe] = true
        local reqs = recipe.ingredients
        if #reqs <= distinct then
          local ok = true
          for _, req in ipairs(reqs) do
            local have = inventory[req.name]
            if not have or have < req.count then
              ok = false;
              break
            end
          end
          if ok
          then result[#result + 1] = recipe
          end
        end
      end
    end
  end

  return result
end

function main()
  setupCraftsByIngredient()

  print('Receitas com wood:')
  for _, recipe in ipairs(getRecipesByIngredientName("wood")) do
    print('  ' .. recipe.name)
  end

  print('Receitas disponiveis:')
  local available = getAvailableRecipes({
    { name = 'wood', count = 5 },
    { name = 'nail', count = 4 },
    { name = 'paint', count = 30 },
  })
  for _, recipe in ipairs(available) do
    print('  ' .. recipe.name)
  end
end

main()
