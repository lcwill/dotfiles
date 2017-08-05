var pushRight = slate.operation("push", {
  "direction" : "right",
  "style" : "bar-resize:screenSizeX/2"
});
var pushLeft = slate.operation("push", {
  "direction" : "left",
  "style" : "bar-resize:screenSizeX/2"
});
var pushTop = slate.operation("push", {
  "direction" : "top",
  "style" : "bar-resize:screenSizeY/2"
});
var pushBottom = slate.operation("push", {
  "direction" : "bottom",
  "style" : "bar-resize:screenSizeY/2"
});
var fullscreen = slate.operation("move", {
  "x" : "screenOriginX",
  "y" : "screenOriginY",
  "width" : "screenSizeX",
  "height" : "screenSizeY"
});

// Cmd+Shift+Enter
slate.bind("return:cmd,shift", function(win) {
  // here win is a reference to the currently focused window
  win.doOperation(fullscreen);
});

// Cmd+Shift+Left
slate.bind("left:cmd,shift", function(win) {
  win.doOperation(pushLeft);
});

// Cmd+Shift+Right
slate.bind("right:cmd,shift", function(win) {
  win.doOperation(pushRight);
});

// Cmd+Shift+Up
slate.bind("up:cmd,shift", function(win) {
  win.doOperation(pushTop);
});

// Cmd+Shift+Down
slate.bind("down:cmd,shift", function(win) {
  win.doOperation(pushBottom);
});
