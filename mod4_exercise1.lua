local function partition(array, start, ending)
    local pivot = array[ending]
    for i = start, ending do
        if array[i] <= pivot then
            array[i], array[start] = array[start], array[i]
            start = start + 1
        end
    end
    return start - 1
end

local function partitionAlt(array, start, ending)
    local rand = math.random(start, ending)
    array[rand], array[ending] = array[ending], array[rand]
    local pivot = array[ending]
    for i = start, ending do
        if array[i] <= pivot then
            array[i], array[start] = array[start], array[i]
            start = start + 1
        end
    end
    return start - 1
end

local function quickSort(array, start, ending)
    start = start or 1
    ending = ending or #array
    if start < ending then
        local partPoint = partition(array, start, ending)
        quickSort(array, start, partPoint - 1)
        quickSort(array, partPoint + 1, ending)
    end
    return array
end

function main()
    local array = {}
    for i = 1, 10000 do
        table.insert(array, math.random(1, 10000))
    end

    local t0 = os.clock()
    local arrayOrder = quickSort(array)
    local t1 = os.clock()
    local arrayWorst = quickSort(arrayOrder)
    local t2 = os.clock()

    print(string.format("Caso medio O(n log n): %d ms", ((t1 - t0) * 1000)))
    print(string.format("Caso ruim O(n^2): %d ms", ((t2 - t1) * 1000)))
    --print(table.concat(arrayOrder, ", "))
end

main()
