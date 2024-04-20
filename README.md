# nui-components.nvim &middot; [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com) [![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](https://github.com/your/your-project/blob/master/LICENSE)

<img src="https://raw.githubusercontent.com/grapp-dev/nui-components.nvim/main/assets/nui-components-logo.png" alt="nui-components.nvim" align="right" width="100" height="100">

> A powerful tool that aims to make UI development in Neovim more accessible, intuitive, and enjoyable.

NuiComponents is a library built on top of [`nui.nvim`](https://github.com/MunifTanjim/nui.nvim), which provides an extensive set of tools for creating user interfaces in Neovim using Lua. With NuiComponents, developers can easily build complex UIs using a simple and intuitive API, which supports various UI elements. Moreover, the library includes advanced features like state management and form validations.

<img src="https://raw.githubusercontent.com/grapp-dev/nui-components.nvim/main/docs/public/gifs/hero.gif" alt="nui-components.nvim">

## Documentation

Full documentation can be found [here](https://nui-components.grapp.dev).

## Installation

To install NuiComponents, you should use your preferred plugin manager.

[Lazy](https://github.com/folke/lazy.nvim)

```lua
{
  "grapp-dev/nui-components.nvim",
  dependencies = {
    "MunifTanjim/nui.nvim"
  }
}
```

[Packer](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "grapp-dev/nui-components.nvim",
  requires = {
    "MunifTanjim/nui.nvim"
  }
}
```

## Discord

Join [Discord](https://discord.gg/Rj2V3keVS4) to get involved with the community, ask questions, and share tips.

## For plugin developers

Consider publishing your plugin to [`luarocks`](https://github.com/nvim-neorocks/sample-luarocks-plugin) to simplify installation with compatible plugin managers like [`rocks.nvim`](https://github.com/nvim-neorocks/rocks.nvim) or `lazy.nvim` extended with [`luarocks.nvim`](https://github.com/vhyrro/luarocks.nvim).

## License

The MIT License.

See [LICENSE](LICENSE)

