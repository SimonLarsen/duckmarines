function love.conf(t)
    t.identity = "duckmarines"
    t.version = "11.2"
    t.console = false

    t.window.title = "Duck Marines"
    t.window.icon = nil
    t.window.width = 700
    t.window.height = 442
    t.window.borderless = false
    t.window.resizable = false
    t.window.fullscreen = false
    t.window.fullscreentype = "exclusive"
    t.window.vsync = true
    t.window.fsaa = 0
    t.window.display = 1

    t.modules.audio = true
    t.modules.event = true
    t.modules.graphics = true
    t.modules.image = true
    t.modules.joystick = true
    t.modules.keyboard = true
    t.modules.math = true
    t.modules.mouse = true
    t.modules.physics = false
    t.modules.sound = true
    t.modules.system = true
    t.modules.timer = true
    t.modules.window = true
end
