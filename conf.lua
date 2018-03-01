function love.conf( t )
  t.console = true
  t.accelerometerjoystick = true
  t.gammacorrect = false

  t.window.title = "Dungeon Bombers";
  t.window.icon = 'res/img/icon.png';
  t.window.width = 1444;
  t.window.height = 816;
  t.window.borderless = false;
  t.window.resizable = true;
  t.window.minwidth = 722;
  t.window.minheight = 408;
  t.window.fullscreen = false;
  t.window.fullscreentype = "desktop";
  t.window.vsync = true;
  t.window.msaa = 0;
  t.window.display = 1;
  t.window.highdpi = false;
  t.window.x = nil
  t.window.y = nil
end
