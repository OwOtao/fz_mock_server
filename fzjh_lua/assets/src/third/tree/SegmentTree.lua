local SegmentTreeNode = {}

function SegmentTreeNode:create(l, r, value)
    if r < l then
        return nil
    end

    local p = setmetatable({}, {__index = SegmentTreeNode})
    p:__init__(l, r, value)
    return p
end

function SegmentTreeNode:__init__(l, r, value)
    self.__l = l
    self.__r = r
    self.__mid = math.floor(l + (r - l) / 2)
    self.__value = value

    self.__leftChild = nil
    self.__rightChild = nil
end

function SegmentTreeNode:update(l, r, value, mergeFunc)
    if (self.__l == self.__r and self.__l == l and self.__r == r) or (self.__l == l and self.__r == r) and self.__leftChild == nil and self.__rightChild == nil then
        self.__value = mergeFunc(self.__value, value)
        return
    elseif self.__l == self.__r or (r < l or r < self.__l or l > self.__r) then
        return
    end

    l = math.max(l, self.__l)
    r = math.min(r, self.__r)

    if self.__leftChild == nil or self.__rightChild == nil then
        if l + (r - l) / 2 <= self.__mid then
            self.__mid = r
        else
            self.__mid = l - 1
        end

        self.__leftChild = SegmentTreeNode:create(self.__l, self.__mid, self.__value)
        self.__rightChild = SegmentTreeNode:create(self.__mid + 1, self.__r, self.__value)
    end

    if self.__leftChild then
        self.__leftChild:update(l, r, value, mergeFunc)
    end
    if self.__rightChild then
        self.__rightChild:update(l, r, value, mergeFunc)
    end
end

function SegmentTreeNode:print()
    if self.__leftChild then
        self.__leftChild:print()
    end

    if self.__rightChild then
        self.__rightChild:print()
    end

    if self.__leftChild == nil and self.__rightChild == nil then
        print(self.__l, self.__r, self.__value)
    end
end

function SegmentTreeNode:sum(l, r)
    if l > r then
        return 0
    elseif self.__l <= l and self.__r >= r and self.__leftChild == nil and self.__rightChild == nil then
        return self.__value * (r - l + 1)
    end

    local ret = 0

    if self.__leftChild then
        ret = ret + self.__leftChild:sum(math.max(l, self.__l), math.min(r, self.__mid))
    end

    if self.__rightChild then
        ret = ret + self.__rightChild:sum(math.max(l, self.__mid + 1), math.min(r, self.__r))
    end

    return ret
end

local SegmentTree = {}
function SegmentTree:create(l, r, value)
    local p = setmetatable({}, {__index = SegmentTree})
    p:__init__(l, r, value)
    return p
end

function SegmentTree:__init__(l, r, value)
    self.__l = l
    self.__r = r
    self.__root = SegmentTreeNode:create(l, r, value)
end

function SegmentTree:update(l, r, value)
    assert(r >= l and l >= self.__l and r >= self.__l and l <= self.__r and r <= self.__r, "r, l 必须在线段树初始范围内并且r>=l")

    self.__root:update(
        l,
        r,
        value,
        function(a, b)
            return b
        end
    )
end

function SegmentTree:add(l, r, value)
    assert(r >= l and l >= self.__l and r >= self.__l and l <= self.__r and r <= self.__r, "r, l 必须在线段树初始范围内并且r>=l")

    self.__root:update(
        l,
        r,
        value,
        function(a, b)
            return a + b
        end
    )
end

function SegmentTree:mul(l, r, value)
    assert(r >= l and l >= self.__l and r >= self.__l and l <= self.__r and r <= self.__r, "r, l 必须在线段树初始范围内并且r>=l")

    self.__root:update(
        l,
        r,
        value,
        function(a, b)
            return a * b
        end
    )
end

function SegmentTree:print()
    self.__root:print()
end

function SegmentTree:sum(l, r)
    assert(r >= l and l >= self.__l and r >= self.__l and l <= self.__r and r <= self.__r, "r, l 必须在线段树初始范围内并且r>=l")
    return self.__root:sum(l, r)
end

return SegmentTree
00000000000