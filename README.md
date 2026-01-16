# sops.vim

A minimal and robust Vim/Neovim plugin to encrypt and decrypt YAML files using [Mozilla SOPS](https://github.com/getsops/sops). 

It is designed to handle both entire files and specific visual selections, making it ideal for managing Kubernetes Secrets or inline encrypted data.

## Features

- **In-place Processing**: Encrypt or decrypt content directly in your buffer.
- **Range Support**: Select a block of YAML (e.g., under `data:`) and process only that part.
- **Indent Preservation**: Automatically handles indentation so your YAML structure remains valid.
- **Undo/Redo Friendly**: Changes are treated as a single modification.
- **Smart Detection**: Prevents double-encryption or decrypting plain text.
- **Configuration Priority**: Automatically detects `.sops.yaml`. If found, it prioritizes the file over global settings.

## Requirements

- [sops](https://github.com/getsops/sops) binary installed in your `$PATH`.

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    "dohq/sops.vim"
}
```

### [plug.vim](https://github.com/junegunn/vim-plug)

```Vim script
Plug 'dohq/sops.vim'
```

## Usage

Command	Description	Default Mapping

| Command | Description | Default Mapping |
| - | - | - |
| :SopsEncrypt [regex] | Encrypt buffer or selection. Optional regex for keys. | <Leader>se |
| :SopsDecrypt | Decrypt buffer or selection. | <Leader>sd |

## Working with Kubernetes Manifests

When editing a Kubernetes Secret, you can visually select the indented data block and run :SopsEncrypt. The plugin strips the leading spaces before passing the text to sops and restores them afterward.

## Configuration

### Global Arguments

If you don't have a .sops.yaml in your project root, or if you need to pass specific flags (like encrypted-regex), set `g:sops_args` in your init.vim or .vimrc.

```Vim script
" Example: Using Age and encrypting only specific keys
let g:sops_args = '--age age1... --encrypted-regex "crt|key|secret|password"'
```

## Custom Mappings

To define your own mappings, add the following to your config:

```Vim script
nnoremap <silent> <Space>e :SopsEncrypt<CR>
vnoremap <silent> <Space>e :SopsEncrypt<CR>
nnoremap <silent> <Space>d :SopsDecrypt<CR>
vnoremap <silent> <Space>d :SopsDecrypt<CR>
```

## License

MIT
