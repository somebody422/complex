--[[
complex.lua
Sam Hedin

A simple lua script for interpreting and manipulating complex numbers
in rectangular and polar form.

Takes a lua expression, with rectangular complex numbers in the form
[real, imaginary] and polar complex numbers in the form {length, angle}.
Parses through the input and replaces those will calls to constructors,
then simply evaluates and prints the expression!

]]


complex = {mode = "degrees", one_revolution = 360}
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
  if new_angle > 0 then new_angle = new_angle % complex.one_revolution
  else new_angle = new_angle % (-1 * complex.one_revolution) end
  return complex.newFromPolar(n1.length * n2.length, new_angle)
  --return complex.newFromRectangular(n1.real*n2.real - n1.imaginary-n2.imaginary, n1.real*n2.imaginary + n2.real*n1.imaginary)
end

function complex.metatable.__div(n1, n2)
  if type(n1) == "number" then n1 = complex.newFromRectangular(n1, 0) end
  if type(n2) == "number" then n2 = complex.newFromRectangular(n2, 0) end
  local new_angle = n1.angle - n2.angle
  if new_angle > 0 then new_angle = new_angle % complex.one_revolution
  else new_angle = new_angle % (-1 * complex.one_revolution) end
  return complex.newFromPolar(n1.length / n2.length, new_angle)
  --local denominator = n2.real^2 + n2.imaginary^2
  --return complex.newFromRectangular(
  --    (n1.real * n2.real + n1.imaginary * n2.imaginary) / denominator,
  --    (n1.imaginary * n2.real - n1.real * n2.imaginary) / denominator
  --)
end

function complex.metatable.__eq(n1, n2)
  if type(n1) ~= "table" or type(n2) ~= "table" then return false end
  if getmetatable(n1) ~= complex.metatable or
     getmetatable(n2) ~= complex.metatable then
    return false
  end
  return (n1.real == n2.real and n1.imaginary == n2.imaginary) or
         (n1.length == n2.length and n1.angle == n2.angle)
end

function complex.metatable.__tostring(c)
  return c.real .. " + j" .. c.imaginary .. ", " .. c.length .. " < " .. c.angle
end


function complex.newFromPolar(length, angle)
  local c = {}
  setmetatable(c, complex.metatable)
  c.length = length
  c.angle = angle
  if complex.mode == "degrees" then
    c.real = c.length * math.cos(math.rad(c.angle))
    c.imaginary = c.length * math.sin(math.rad(c.angle))
  else --using radians
    c.real = c.length * math.cos(c.angle)
    c.imaginary = c.length * math.sin(c.angle)
  end
  return c
end

function complex.newFromRectangular(real, imaginary)
  local c = {}
  setmetatable(c, complex.metatable)
  c.real = real
  c.imaginary = imaginary
  c.length = math.sqrt(c.real^2 + c.imaginary^2)
  if complex.mode == "degrees" then
    c.angle = math.deg(math.atan(c.imaginary / c.real))
  else
    c.angle = math.atan(c.imaginary / c.real)
  end
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

-- Do a couple of unit tests
function testComplex()
  local function testSingleComplex(str, res)
    local parsed_string = "return ( " .. parseInput(str) .. " )"
    local fun = loadstring(parsed_string)
    local my_res = fun()
    if my_res == res then
      io.write("\"", str, "\" passed\n")
    else
      io.write("ERROR:    \"", str, "\" failed... got\n          ", tostring(my_res), "\n          when should have gotten\n          ", tostring(res), "\n")
    end
  end
  testSingleComplex("[4, 6] - [1, 4]", complex.newFromRectangular(3, 2))
  testSingleComplex("[3, 6] + [-6, 3]", complex.newFromRectangular(-3, 9))
  testSingleComplex("[2, 3] * [5, 10]", complex.newFromRectangular(-20, 35))
  testSingleComplex("{5, 20} * {10, 30}", complex.newFromPolar(50, 50))
  testSingleComplex("10 * [2, 3]", complex.newFromRectangular(20, 30))
  testSingleComplex("{5, 25} * {2, 350}", complex.newFromPolar(10, 15))
  testSingleComplex("{5, 25} * {2, -395}", complex.newFromPolar(10, -10))
  testSingleComplex("[1, 4] / [4, 5]", complex.newFromRectangular(24/41, 11/41))
  testSingleComplex("[8, 10] / 2", complex.newFromRectangular(4, 5))
  testSingleComplex("{15, 10} / {2, 7}", complex.newFromPolar(7.5, 3))
  testSingleComplex("([2, 3] + [4, 6]) / ([7, 7] - [3, -3])", complex.newFromRectangular(113/116, -24/116))
  testSingleComplex("({50, 30} * [5, 5]) / {10, -20}", complex.newFromPolar(35.35, 95))
  testSingleComplex("{3, 27} - {6, -40}", complex.newFromRectangular(-1.92, 5.22))
end




if arg[1] == nil then
  print("Usage: lua complex.lua formula")
  return 1
end

local s = parseInput(arg[1])
local f = loadstring("print(" .. s .. ")")
f()
