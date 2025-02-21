# DotNet Tools plugin for NeoVim

This plugin is a simple wrapper around the `dotnet` command line tool.
It provides a few commands to make it easier to work with .NET projects in NeoVim.

## Remarks

This plugin is still in development and may not work as expected.
Please report any issues you find.
It is only currently tested on debian based linux distributions.
It may not work on other operating systems for now.

## Installation

This plugin requires the `dotnet` command line tool to be installed.
You can install it from [here](https://dotnet.microsoft.com/download).

You can install this plugin using Lazy by running the following:

```lua
return {
  'helto4real/dotnet-tools.nvim',
  requires = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope.nvim' }
}
```

## Commands

- `DotNetToolTest` - Run the tests in the current project/solution at
the current directory.
- `DotNetToolBuild` - Build the current project/solution at the current directory.
- `DotNetToolOutdated` - Check for outdated dependencies in the current project/solution
at the current directory.
- `DotNetToolOutdatedUpgrade` - Check for outdated dependencies in the current project/solution
at the current directory and upgrade them.

You will need to install the outdated tool before using those commands.
