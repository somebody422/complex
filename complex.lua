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
  local new_angle = n1.angle + n2.angle
  if new_angle > 0 then new_angle = new_angle % (2*math.pi)
  else new_angle = new_angle % (-2*math.pi) end
  return complex.newFromPolar(n1.length * n2.length, new_angle)
end

function complex.metatable.__div(n1, n2)
  if type(n1) == "number" then n1 = complex.newFromRectangular(n1, 0) end
  if type(n2) == "number" then n2 = complex.newFromRectangular(n2, 0) end
  local new_angle = n1.angle - n2.angle
  if new_angle > 0 then new_angle = new_angle % (2*math.pi)
  else new_angle = new_angle % (-2*math.pi) end
  return complex.newFromPolar(n1.length / n2.length, new_angle)
end


function complex.metatable.__tostring(c)
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
  -- make sure angle is in the correct quadrant
  if c.real < 0 then c.angle = c.angle + math.pi end
  return c
end


-- replace {...} with calls to complex.newFromPolar and [...]
--  with calls to complex.newFromRectangular
function parseInput(str)
  str = string.gsub(str, "{([%d.-]+), ?([%d.-]+)}", "complex.newFromPolar(%1, %2)")
  str = string.gsub(str, "%[([%d.-]+), ?([%d.-]+)]", "complex.newFromRectangular(%1, %2)")
  return str
end



if arg[1] == nil then
  print("Usage: lua complex.lua formula")
else
  --parseInput(table.concat(arg, ' ', 1))
  local s = parseInput(arg[1])
  --s = "print(" .. s .. ")"
  print(s)
  local f = loadstring("print(" .. s .. ")")
  f()
end
