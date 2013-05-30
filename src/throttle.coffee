makePromise = require "make-promise"

module.exports = throttle = (concurrency, fn) ->
  throw new Error "Concurrency must be equal or higher than 1." unless concurrency >= 1
  throw new Error "Worker must be a function." unless typeof fn is "function"
  numRunning = 0
  queue = []
  
  startJobs = ->
    startJob job while numRunning < concurrency and job = queue.shift()
      
  startJob = (job) ->
    rejectedHandler = makeRejectedHandler job
    numRunning++
    try promise = fn.apply job.context, job.arguments
    catch error then return rejectedHandler error
    try promise.then makeFulfilledHandler(job), rejectedHandler
    catch error then return rejectedHandler error
  
  makeFulfilledHandler = (job) -> 
    (result) ->
      numRunning--
      job.callback null, result
      startJobs() if queue.length

  makeRejectedHandler = (job) -> 
    (error) ->
      numRunning--
      job.callback error
      startJobs() if queue.length
  
  (args...) ->
    makePromise (callback) =>
      queue.push
        context: this
        arguments: args
        callback: callback
      startJobs()