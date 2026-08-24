local primeNumbers = {1217, 1627, 2179, 2909, 3881, 6907, 9209, 12281, 16381, 21841, 29123, 38833, 51787, 69061, 92083}
local M = math.random(4061, 40615)
local factorA = math.random(4061, 40615)
local factorB = math.random(4061, 40615)

local function confuse(t, extra)
    if type(t) == "number" then
        return ((t * factorA + factorB) * string.byte(extra)) % M
    elseif type(t) == "string" then
        local hash = 0
        local extra = string.byte(extra)
        for i = 1, #t do
            hash = (hash * 128 + (string.byte(t, i) * factorA + factorB) * extra) % M
        end
        return hash
    end
end

return confuse
0000000000000