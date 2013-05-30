require("mocha-as-promised")()

throttle = require "../"
assert = require "assert"

timeout = 50
length = 200

makePromise = require "make-promise"
{collect} = require "faithful"

describe "function throttled to 10", ->
  it "calls fn with every value in the array", ->
    argumentsUsed = (false for i in [0...100])
    inputs = (i for i in [0...100])
    fn = throttle 10, (value) -> makePromise (cb) -> 
      setImmediate ->
        argumentsUsed[value] = true
        cb()
    collect((fn input for input in inputs)).then ->
      assert.ok argumentsUsed[input], "Argument #{input} was not used." for input in inputs
  
  it "calls fn with arguments in original order", ->
    inputs = (i for i in [0...length])
    argsUsed = (false for i in [0...100])
    fn = throttle 10, (arg) ->
      assert !argsUsed[j], "Arg #{j} has been used before arg #{arg}." for j in [arg...length]
      argsUsed[arg] = true
      makePromise (cb) -> delayRandomly timeout, -> cb()
    collect (fn input for input in inputs)

  it "fulfills with right value", ->
    inputs = (i for i in [0...length])
    expected = (i*2 for i in [0...length])
    argsUsed = (false for i in [0...100])
    fn = throttle 10, (arg) ->
      assert !argsUsed[j], "Arg #{j} has been used before arg #{arg}." for j in [arg...length]
      argsUsed[arg] = true
      makePromise (cb) -> delayRandomly timeout, -> cb null, arg*2
    collect(fn input for input in inputs).then (values) ->
      assert.equal expected[i], values[i] for i in [0...length]

delayRandomly = (maxTimeout, fn) ->
  delay (Math.round(Math.random() * maxTimeout)), fn
delay = (timeout, fn) -> setTimeout fn, timeout