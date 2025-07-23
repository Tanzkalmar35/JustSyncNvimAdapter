# JustSyncNvimAdapter.nvim

A Neovim plugin that acts as an adapter for the [JustSync](https://github.com/Tanzkalmar35/JustSync) project. It sends an HTTP request to a configurable endpoint every time a file is saved.

## Installation

Install the plugin with your favorite plugin manager:

### Packer

```lua
use { 'Tanzkalmar35/JustSyncNvimAdapter.nvim' }
```

### vim-plug

```vim
Plug 'Tanzkalmar35/JustSyncNvimAdapter.nvim'
```

### Lazy

```lua
{
	"Tanzkalmar35/JustSyncNvimAdapter",
	opts = {
		url = "http://localhost:10000/send-sync",
		method = "POST", -- optional: Defaults to POST
	},
}
```

## Configuration

Configure the plugin by calling the `setup` function in your Neovim configuration.
Only if you don't use lazy.

```lua
require('JustSyncNvimAdapter').setup({
    url = "http://localhost:3000/endpoint",
    method = "POST",
    pattern = "*" -- Optional: defaults to "*"
})
```

## Usage

The plugin provides the following commands:

* `:JustSyncStart`: Starts the adapter. It will now send a request on every file save.
* `:JustSyncStop`: Stops the adapter.

## Dependencies

This plugin requires `curl` to be installed on your system.
