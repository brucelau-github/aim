# Introduction

This plugin leverages the ollama framework to utilize a local Large Language Model (LLM) running on your machine to deliver its AI capabilities. The LLM's data remains local, ensuring fast processing and privacy.

To install ollama, please consult their official guidelines available at [https://ollama.com/](https://ollama.com/).

## Integration with Vim

The plugin can be integrated into Vim using Vundle or other compatible bundle plugins.

## Commands

The following commands are available:

- `:Aask`: Sends the current line to ollama, allowing for real-time feedback and taking advantage of the range modifier option.
- `:Arewrite`: Rewrites the current paragraph with suggested corrections.
- `:Aenrich`: Expands the context, generating longer and error-free content.
- `:Atalk`: Allows users to input their own instructions or prompts for the LLM.

## Configuration

The plugin's functionality is currently in a work-in-progress (WIP) state. Future updates are anticipated, although detailed plans remain under consideration due to time constraints.

For reference, this plugin employs the llama3.2 model, which has demonstrated relative performance and efficiency while still being compact enough to run on most modern laptops.
