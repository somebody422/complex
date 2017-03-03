complex = {}
complex.metatable = {}



function complex.metatable.__add(n1, n2)
  if type(n1) == "number" then n1 = complex.newFromRectangular(n1, 0) end
  if type(n2) == "number" then n2 = complex.newFromRectangular(n2, 0) end
  return complex.newFromRectangular(n1.real + n2.real, n1.imaginary + n2.imaginary)
end

function complex.metatable.__sub(n1, n2)
  if type(n1) == "number" then n1 = complex.newFromRectangular(n1, 0) end
  if type(n2) == "number" then n2 = complex.newFromRectangular(n2, 0) end
  return complex.newFromRectangular(n1.real - n2.real, n1.imaginary - n2.imaginary)
end

function complex.metatable.__mul(n1, n2)
  if type(n1) == "number" then n1 = complex.newFromRectangular(n1, 0) end
  if type(n2) == "number" then n2 = complex.newFromRectangular(n2, 0) end
  return complex.newFromPolar(n1.length * n2.length, n1.angle + n2.angle)
end

function complex.metatable.__div(n1, n2)
  if type(n1) == "number" then n1 = complex.newFromRectangular(n1, 0) end
  if type(n2) == "number" then n2 = complex.newFromRectangular(n2, 0) end
  print("in divide:")
  print(n1)
  print(n2)
  print(n1.length)
  print(n1.length / n2.length)
  return complex.newFromPolar(n1.length / n2.length, n1.angle - n2.angle)
end

--[[
function complex.metatable.__div(c, other)
  if other == nil then
    error("Trying to multiply complex number to nil value")
  elseif type(other) == "number" then
    return complex.newFromPolar(c.length / other, c.angle)
  elseif type(other) == "table" then
    local m = getmetatable(other)
    if m ~= nil and m == complex.metatable then
      return complex.newFromPolar(c.length / other.length,
          c.angle - other.angle)
    end
  end
end
]]



function complex.metatable.__tostring(c)
  --return c.real .. " + j" .. c.imaginary
  return c.real .. " + j" .. c.imaginary .. ", " .. c.length .. " < " .. c.angle
end


function complex.newFromPolar(length, angle)
  local c = {}
  setmetatable(c, complex.metatable)
  c.length = length
  c.angle = angle
  c.real = c.length * math.cos(c.angle)
  c.imaginary = c.length * math.sin(c.angle)
  return c
end

function complex.newFromRectangular(real, imaginary)
  local c = {}
  setmetatable(c, complex.metatable)
  c.real = real
  c.imaginary = imaginary
  c.length = math.sqrt(c.real^2 + c.imaginary^2)
  c.angle = math.atan(c.imaginary / c.real)
  return c
end



-- replace {...} with calls to complex.newFromPolar and [...]
--  with calls to complex.newFromRectangular
function parseInput(str)
  print("parseInput called with: " .. str)

  str = string.gsub(str, "{([%d.-]+),  ?([%d.-]+)}", "complex.newFromPolar(%1, %2)")
  str = string.gsub(str, "%[([%d.-]+), ?([%d.-]+)]", "complex.newFromRectangular(%1, %2)")
  --for length, angle in string.gmatch(str, "{([%d.-]+), ?([%d.-]+)}") do
  --  print("Found polar: " .. length .. " + j" .. angle)
  --end
  --for real, imaginary in string.gmatch(str, "%[([%d.-]+), ?([%d.-]+)]") do
  --  print("Found rectangular: " .. real .. " < " .. imaginary)
  --end
  return str
end



print("arg:")
for k,v in pairs(arg) do
  print(k .. ": " .. v)
end

if arg[1] == nil then
  print("Usage: lua complex.lua formula")
else
  --parseInput(table.concat(arg, ' ', 1))
  local s = parseInput(arg[1])
  s = "print(" .. s .. ")"
  print(s)
  local f = loadstring("print(" .. s .. ")")
  f()
end
