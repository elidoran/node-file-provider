fs = require 'fs'
net = require 'net'

# let's tell the system who we are
process.title = 'file-provider'

# use `nuc` for configuration values
values = require('nuc') id:'file-provider', defaults: port:34543

# read the file we are going to provide
try
  file = fs.readFileSync values.filePath
catch error
  console.error 'Unable to read file from',values.filePath
  console.error ' Error:',error.message
  process.exit(1) # TODO: determine which return code is proper

server = net.createServer (socket) ->

  # listen for errors on the socket
  socket.on 'error', (error) ->

    # write them to stderr
    console.error 'Client error:', error

    # destroy the socket (I think this happens on its own from error..)
    socket.destroy()

  # all we do with client is send them the file and close the connection.
  socket.end file, 'binary'

serverOptions = port:values.port

if values.host? then serverOptions.host = values.host

server.inUseRetryCount = 0

listen = ->
  server.listen serverOptions, (socket) ->
    console.log 'Server:'
    console.log '  Providing file:',values.filePath
    console.log '  Listening on',server.address()

server.on 'error', (error) ->
  if error.code is 'EADDRINUSE'
    if server.inUseRetryCount < 3
      console.log 'Address in use, retrying in 3 seconds...'
      server.inUseRetryCount++
      setTimeout (->
        server.close()
        listen()
      ), 3000
    else
      console.error "Address in use. Exiting after #{server.inUseRetryCount} retries."
      server.close()
  else
    console.error 'Server error:',error.message
    server.close()

listen()
