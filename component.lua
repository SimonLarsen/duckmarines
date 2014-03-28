local Component = {}
Component.__index = Component

function Component:keypressed(k) return false end
function Component:textinput(text) return false end
function Component:click(x, y) end
function Component:draw() end

return Component
