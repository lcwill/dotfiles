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
var pushRightThird = slate.operation("move", {
  "x" : "screenOriginX + 2*screenSizeX/3",
  "y" : "screenOriginY",
  "width" : "screenSizeX/3",
  "height" : "screenSizeY"
});
var pushLeftThird = slate.operation("move", {
  "x" : "screenOriginX",
  "y" : "screenOriginY",
  "width" : "screenSizeX/3",
  "height" : "screenSizeY"
});
var pushCenterThird = slate.operation("move", {
  "x" : "screenOriginX + screenSizeX/3",
  "y" : "screenOriginY",
  "width" : "screenSizeX/3",
  "height" : "screenSizeY"
});
var pushTopRight = slate.operation("move", {
  "x" : "screenOriginX + screenSizeX/2",
  "y" : "screenOriginY",
  "width" : "screenSizeX/2",
  "height" : "screenSizeY/2"
});
var pushTopLeft = slate.operation("move", {
  "x" : "screenOriginX",
  "y" : "screenOriginY",
  "width" : "screenSizeX/2",
  "height" : "screenSizeY/2"
});
var pushBottomLeft = slate.operation("move", {
  "x" : "screenOriginX",
  "y" : "screenOriginY + screenSizeY/2",
  "width" : "screenSizeX/2",
  "height" : "screenSizeY/2"
});
var pushBottomRight = slate.operation("move", {
  "x" : "screenOriginX + screenSizeX/2",
  "y" : "screenOriginY + screenSizeY/2",
  "width" : "screenSizeX/2",
  "height" : "screenSizeY/2"
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

// Cmd+Shift+F
slate.bind("f:cmd,shift", function(win) {
  win.doOperation(pushBottomLeft);
});

// Cmd+Shift+J
slate.bind("j:cmd,shift", function(win) {
  win.doOperation(pushBottomRight);
});

// Cmd+Shift+G
slate.bind("g:cmd,shift", function(win) {
  win.doOperation(pushTopLeft);
});

// Cmd+Shift+8
slate.bind("8:cmd,shift", function(win) {
  win.doOperation(pushLeftThird);
});

// Cmd+Shift+9
slate.bind("9:cmd,shift", function(win) {
  win.doOperation(pushCenterThird);
});

// Cmd+Shift+0
slate.bind("0:cmd,shift", function(win) {
  win.doOperation(pushRightThird);
});

// Cmd+Shift+H
slate.bind("h:cmd,shift", function(win) {
  win.doOperation(pushTopRight);
});
