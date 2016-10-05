# file provider

Runs a server which sends the contents of a file to each client.

It closes the connection after sending it.

Default port is *34543*.
Must provide a *filePath* value.

Configuration is done via [nuc](https://github.com/elidoran/node-nuc).

For example, make a user to run the CLI as a service. Then, in that user's home directory, place a file named `file-provider.json` with the configuration.

```json
{
  "port" : 12345
  , "filePath" : "/path/to/the/file"
}
```

### MIT License
