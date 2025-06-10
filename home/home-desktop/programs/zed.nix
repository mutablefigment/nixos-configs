{
  pkgs,
  ...
}: {

  home.file.".zed_server".source = "${pkgs.zed-editor.remote_server}/bin";

  programs.zed-editor = {
    enable = true;
    installRemoteServer = true;

    extensions = [
      "nix"
      "toml"
      "elixir"
      "make"
      "go"
      "zig"
    ];

    userSettings = {
    lsp = {
        rust-analyzer = {

            binary = {
                #                        path = lib.getExe pkgs.rust-analyzer;
                path_lookup = true;
            };
        };
        nix = {
            binary = {
                path_lookup = true;
            };
        };

        elixir-ls = {
            binary = {
                path_lookup = true;
            };
            settings = {
                dialyzerEnabled = true;
            };
        };

        go = {
          gopls = {
            initialization_options = {
                assignVariableType = true;
                compositeLiteralField = true;
                compositeLiteralType = true;
                constantValue = true;
                functionTypeParameter = true;
                parameterName = true;
                rangeVariableTypes = true;
            };
          };
        };

    };


            languages = {
                "Elixir" = {
                    language_servers = ["!lexical" "elixir-ls" "!next-ls"];
                    format_on_save = {
                        external = {
                            command = "mix";
                            arguments = ["format" "--stdin-filename" "{buffer_path}" "-"];
                        };
                    };
                };
                "HEEX" = {
                    language_servers = ["!lexical" "elixir-ls" "!next-ls"];
                    format_on_save = {
                        external = {
                            command = "mix";
                            arguments = ["format" "--stdin-filename" "{buffer_path}" "-"];
                        };
                    };
                };
            };

            vim_mode = false;
            ## tell zed to use direnv and direnv can use a flake.nix enviroment.
            load_direnv = "shell_hook";
            base_keymap = "VSCode";
            theme = {
                mode = "system";
                light = "One Light";
                dark = "Ayu Mirage";
            };
            show_whitespaces = "all" ;
            show_indent_guide = true;
            ui_font_size = 14;
            buffer_font_size = 14;

            telemetry = {
              diagnostics= false;
              metrics= false;
            };

            lanaguage_models = {
              ollama = {
                api_url = "http://localhost:11434";
                available_models = [
                  {
                    name = "qwen2.5-coder";
                    display_name = "qwen 2.5 coder 32k";
                    max_tokens = 32768;
                  }
                ];
              };
            };

            assistant = {
                enabled = true;
                version = "2";
                default_open_ai_model = null;
                ### PROVIDER OPTIONS
                ### zed.dev models { claude-3-5-sonnet-latest } requires github connected
                ### anthropic models { claude-3-5-sonnet-latest claude-3-haiku-latest claude-3-opus-latest  } requires API_KEY
                ### copilot_chat models { gpt-4o gpt-4 gpt-3.5-turbo o1-preview } requires github connected
                default_model = {
                    provider = "copilot_chat";
                    model = "gpt-4o";
                };

                inline_alternatives = [
                    {
                        provider = "copilot_chat";
                        model = "claude-3-5-sonnet-latest";
                    }
                ];
            };
    };
  };
}
