[<img src="https://img.shields.io/badge/App_Store-0D96F6?&logo=app-store&logoColor=white">](https://apps.apple.com/gb/app/enchanted-llm/id6474268307)
![Swift](https://img.shields.io/badge/swift-F54A2A?&logo=swift&logoColor=white)
![Release](https://img.shields.io/github/v/release/augustdev/enchanted)
![Stars](https://img.shields.io/github/stars/augustdev/enchanted.svg)
[<img src="https://img.shields.io/twitter/url?url=https%3A%2F%2Ftwitter.com%2Famgauge">](https://twitter.com/amgauge)
![iOS](https://img.shields.io/badge/iOS-000000?&logo=os&logoColor=white)
![macOS](https://img.shields.io/badge/macOS-000000?style=?&logo=os&logoColor=white)
![visionOS](https://img.shields.io/badge/visionOS-000000?style=?&logo=os&logoColor=white)

# Enchanted

Enchanted is open source, [Ollama](https://github.com/jmorganca/ollama) compatible, elegant macOS/iOS/visionOS app for working with privately hosted models such as Llama 2, Mistral, Vicuna, Starling and more. It's essentially ChatGPT app UI that connects to your private models. The goal of Enchanted is to deliver a product allowing unfiltered, secure, private and multimodal experience across all of your devices in iOS ecosystem (macOS, iOS, Watch, Vision Pro).

If you like the project, consider leaving a ⭐️ and following on [𝕏](https://twitter.com/amgauge).

## App Store

[<img src="https://i.ibb.co/7WXt3qZ/download.png">](https://apps.apple.com/gb/app/enchanted-llm/id6474268307)

Note: You will need to run your own Ollama server to use the app. Read instructions below.

## Demo

[<img src="./assets/promo.png">](https://www.youtube.com/watch?v=zW3roZ_vM5Q)

[Vision Pro Demo](https://www.youtube.com/watch?v=y4ZeGU5IdHA)

## Showcase

### Macbook

![image](https://github.com/AugustDev/enchanted/assets/5672094/32a6a203-19a2-4cc1-adc9-cfac8445dd42)

#### Dark mode

![image](https://github.com/AugustDev/enchanted/assets/5672094/6202d235-6c34-4f79-b08a-a372fca0439e)

#### Settings

<img src="https://github.com/AugustDev/enchanted/assets/5672094/b03acfc7-cbc3-4bab-92cd-73d3eb75b47e" width="1000" height="100%">

#### Completions

 <img src="https://github.com/AugustDev/enchanted/assets/5672094/5ca80a65-1bec-4d6c-8065-f0a26861c3c2" width="1000" height="100%">

#### Use from anywhere

https://github.com/AugustDev/enchanted/assets/5672094/221d2a48-9218-4579-b284-a1ad2845e4d6

#### Build custom prompt templates and use anywhere

<img width="599" alt="Xnapper-2024-05-02-18 57 19" src="https://github.com/AugustDev/enchanted/assets/5672094/7b69fe50-5399-4c0b-a269-f28353b8ca27">

https://github.com/AugustDev/enchanted/assets/5672094/8bdebd5e-2910-4855-bb10-91239cafbc28

#### Custom completion

https://github.com/AugustDev/enchanted/assets/5672094/2ef476e7-8fc5-4992-9152-6df3847056d6

### iPhone

Multimodal

<img src="https://github.com/AugustDev/enchanted/assets/5672094/f2a7dafa-9470-4689-9f5a-27b6eb0e168d" width="1000" height="100%">

Markdown

<img src="https://github.com/AugustDev/enchanted/assets/5672094/9caefcb2-69eb-46d0-8d4f-b6269d7c2937" width="1000" height="100%">

Conversation history

<img width="959" alt="Xnapper-2024-05-03-12 00 28" src="https://github.com/AugustDev/enchanted/assets/5672094/7dade8ec-e94d-4936-9237-f2f2bc1533f2">

### Vision Pro

<img width="1534" alt="image" src="https://github.com/AugustDev/enchanted/assets/5672094/810f600a-4377-48e3-9c94-7bb90b78acaf">

<img width="1496" alt="image" src="https://github.com/AugustDev/enchanted/assets/5672094/6014a0b4-03ed-4def-b26c-b9baefad3781">




- Text to Speech (Read Aloud)
- Conversation history included in the API calls
- Dark/Light mode
- Conversation history is stored on your device
- Markdown support (nicely displays tables/lists/code blocks)
- Voice prompts
- Image attachments for prompts
- Specify system prompt used for every conversations
- Edit message content or submit message with different model
- Delete single conversation / delete all conversations
- macOS Spotlight panel <kbd>Ctrl</kbd>+<kbd>⌘</kbd>+<kbd>K</kbd>
- All features works offline

## Usage instructions

Enchanted requires Ollama v0.1.14 or later.

### Case 1. You run Ollama server with public access

1. Download Enchanted app from the App Store.
2. In App Settings specify your server endpoint.

You're done! Make a prompt.

### Case 2. You run Ollama on your computer

[Video instructions here](https://www.youtube.com/watch?v=SFeVCiLOABM)

1. Start Ollama server and download models for usage.
2. Install ngrok forward your Ollama server to make it accessible publicly

   ```shell
   ngrok http 11434 --host-header="localhost:11434"
   ```

3. Copy "Forwarding" URL that will look something like `https://b377-82-132-216-51.ngrok-free.app`. Your Ollama server API is now accessible through this temporary URL.
4. Download Enchanted app from the App Store.
5. In App Settings specify your server endpoint.

   You're done! Make a prompt.

# Development

## Xcode MCP Server (Warp Terminal)

This project includes an MCP (Model Context Protocol) server (`MCPBridge`) that integrates Xcode with AI-powered terminals like [Warp](https://www.warp.dev). It enables tools such as building the project, running tests, searching code, and rendering SwiftUI previews — all from the terminal.

### Troubleshooting: `MCP_XCODE_PID environment variable not set`

If you see this error in the MCP server logs:

```
mcpbridge/MCPBridge.swift:125: Fatal error: MCP_XCODE_PID environment variable not set and no running Xcode processes found
```

**Cause:** The MCPBridge requires a running Xcode instance to connect to. It looks for either the `MCP_XCODE_PID` environment variable or a running Xcode process.

**Fix:**

1. Open Xcode (`open -a Xcode`) **before** launching Warp.
2. Restart Warp so it re-initializes the MCP server with Xcode available.
3. Verify the connection in Warp under **Settings → MCP Servers**, or by using any Xcode MCP tool (e.g. `XcodeListWindows`).

Alternatively, set the `MCP_XCODE_PID` environment variable to the PID of a running Xcode process:

```shell
export MCP_XCODE_PID=$(pgrep -x Xcode)
```

# Contact

For any questions please do not hesitate to contact me at augustinas@subj.org

# Author

Augustinas Malinauskas
