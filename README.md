# DotNet Tools plugin for NeoVim
This plugin is a simple wrapper around the `dotnet` command line tool. It provides a few commands to make it easier to work with .NET projects in NeoVim.

## Installation
This plugin requires the `dotnet` command line tool to be installed. You can install it from [here](https://dotnet.microsoft.com/download).

You can install this plugin using LazyGit by running the following command:

```lua
return {
  'helto4real/dotnet-tools.nvim',
  requires = { 'nvim-lua/plenary.nvim' }
}
```

## Commands
- `DotNetToolTest` - Run the tests in the current project/solution att the current directory.
- `DotNetToolBuild` - Build the current project/solution at the current directory.
- `DotNetToolOutdated` - Check for outdated dependencies in the current project/solution at the current directory.
- `DotNetToolOutdatedUpgrade` - Check for outdated dependencies in the current project/solution at the current directory and upgrade them.

You will need to install the outdated tool before using those commands.
