require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls", "clangd", "ts_ls", "bashls", "gopls", "pyright",
  "arduino_language_server", "csharp_ls", "openscad_lsp", "nixd", "vala_ls", "tombi", "gdscript", "yamlls" }

vim.lsp.config("nixd", {
  settings = {
    nixd = {
      nixpkgs = {
        expr = "import <nixpkgs> { }"
      },
      formatting = {
        command = { "nixfmt" }
      },
      options = {
        nixos = {
          expr = '(builtins.getFlake "./.").nixosConfigurations."nixos-laptop".options'
        }
      }
    }
  }
})

vim.lsp.config("yamlls", {
  settings = {
    yaml = {
      format = { enable = true },
      schemas = {
        ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
        ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = { "*compose*.y*ml" },
      }
    }
  }
})

vim.lsp.config("vala_ls", {
  single_file_support = true,
})

vim.lsp.enable(servers)
