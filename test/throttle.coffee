assert = require "assert"
makePromise = require "make-promise"

throttle = require "../"

describe "throttle", ->
  it "can be called", ->
    throttle 1, ->

  it "concurrency must be equal or higher than 1", ->
    try throttle 0.999, ->
    catch error then return
    throw new Error "No error."

  it "given function must be a function", ->
    try throttle 1, ""
    catch error then return
    throw new Error "No error."

describe "a throttled function", ->
  it "returns a promise", ->
    fn = throttle 1, ->
    p = fn 1
    assert typeof p.then is "function"
    
  it "returns a promise that fulfills if given function is proper", ->
    fn = throttle 1, -> makePromise (cb) -> cb null
    fn 1
    
  it "returns a promise that fails if given function does not return promise", ->
    fn = throttle 1, -> 1 # no promise
    fn(1).then
      onRejected: (err) -> assert.equal err.toString(), "TypeError: Object 1 has no method 'then'"
      onFulfilled: -> throw new Error "Should have failed."

  it "returns a promise that fails if given function fails", ->
    fn = throttle 1, -> throw new Error "given function failed"
    fn(1).then
      onRejected: (err) -> assert.equal err.toString(), "Error: given function failed"
      onFulfilled: -> throw new Error "Should have failed."
      
  it "returns a promise that fails if given function returns rejected promise", ->
    fn = throttle 1, -> makePromise (cb) -> cb new Error "job failed"
    fn(1).then
      onRejected: (err) -> assert.equal err.toString(), "Error: job failed"
      onFulfilled: -> throw new Error "Should have failed."
      
  it "returns a promise that fails if given function fails", ->
    fn = throttle 1, -> throw new Error "given function failed"
    fn(1).then
      onRejected: (err) -> assert.equal err.toString(), "Error: given function failed"
      onFulfilled: -> throw new Error "Should have failed."