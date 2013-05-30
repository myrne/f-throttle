require("mocha-as-promised")()
require("source-map-support").install()

throttle = require "../"
assert = require "assert"

timeout = 100
length = 20

makePromise = require "make-promise"
{collect} = require "faithful"

describe "function throttled to 1", ->
  it "calls fn with every value in the array", (next) ->
    argumentsUsed = (false for i in [0...100])
    inputs = (i for i in [0...100])
    fn = throttle 1, (value) ->
      makePromise (cb) -> 
        setImmediate -> cb null, argumentsUsed[value] = true
    collect((fn input for input in inputs)).then ->
      assert.ok argumentsUsed[input], "Argument #{input} was not used." for input in inputs
  
  it "calls fn with arguments in original order", (next) ->
    argsUsed = (false for i in [0...length])
    inputs = (i for i in [0...length])
    callOrder = []
    fn = throttle 1, (arg) ->
      assert !argsUsed[i], "Arg #{i} has been used before arg #{arg}." for i in [arg...length]
      argsUsed[arg] = true
      callOrder.push arg
      makePromise (cb) -> delayRandomly timeout, -> cb()
    collect (fn input for input in inputs)
    
  it "does not start next job before previous job is finished", ->
    argsUsed = (false for i in [0...length])
    inputs = (i for i in [0...length])
    finished = (false for i in [0...length])
    makeResolver = (i) -> 
      (result) ->
        finished[i] = true
    fn = throttle 1, (value) ->
      assert finished[j], "#{j} should have finished beforehand." for j in [0...value]
      assert !finished[j], "#{j} should not have finished already." for j in [value...length]
      makePromise (cb) -> delayRandomly timeout, -> cb()
    collect((fn(input).then makeResolver(i)) for input,i in inputs)
      
        
delayRandomly = (maxTimeout, fn) ->
  delay (Math.round(Math.random() * maxTimeout)), fn
delay = (timeout, fn) -> setTimeout fn, timeout