**ABANDONED**

# Writedown

WriteDown is a interface to note taking and todo managing applications.

## Usage

```ruby
require 'writedown'

init_adapter(:Adapter, path: 'example.json', more: options)
Write.search('descri[bp]')
```

If you are building a command line interface, then you may use the
`receive_input` method in `bin/my_app`

```ruby
#!/usr/bin/env ruby

require 'writedown'
require 'my_app'

WriteDown.receive_input(MyApp)
```

And `MyApp` implements three module functions: `add`, `list` and `attack`.

Then `my_app` accepts input from stdin, file or command line arguments.

```sh
echo 'new note' | my_app
my_app new_note.txt
my_app 'new note'
my_app '/search/'
```

## Adapters

Adapters communicate with backends. An adapter is expected to implement following module functions:

- add
- archive
- edit
- list
- remove
- search
