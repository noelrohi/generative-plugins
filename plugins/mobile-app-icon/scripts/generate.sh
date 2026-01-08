#!/bin/bash
set -e

# Use CLAUDE_PLUGIN_ROOT for portable paths
PLUGIN_DIR="${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/plugins/mobile-app-icon}"
CONFIG_FILE="$PLUGIN_DIR/config.json"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "ERROR: Config not found at $CONFIG_FILE"
    echo "Create it with: {\"openai_api_key\": \"...\", \"gemini_api_key\": \"...\"}"
    exit 1
fi

MODEL="gpt-image-1"
SIZE="1024x1024"
QUALITY="auto"
STYLE=""
RAW=false
NUM=1
BACKGROUND="auto"
OUTPUT="icon.png"
PROMPT=""
ASPECT_RATIO="1:1"

while [[ $# -gt 0 ]]; do
    case $1 in
        --model) MODEL="$2"; shift 2 ;;
        --size) SIZE="$2"; shift 2 ;;
        --quality) QUALITY="$2"; shift 2 ;;
        --style) STYLE="$2"; shift 2 ;;
        --raw) RAW=true; shift ;;
        --num) NUM="$2"; shift 2 ;;
        --background) BACKGROUND="$2"; shift 2 ;;
        --output) OUTPUT="$2"; shift 2 ;;
        --aspect-ratio) ASPECT_RATIO="$2"; shift 2 ;;
        -*) echo "Unknown option: $1"; exit 1 ;;
        *) PROMPT="$1"; shift ;;
    esac
done

if [[ -z "$PROMPT" ]]; then
    echo "Usage: generate.sh \"prompt\" [options]"
    exit 1
fi

BASE_RULES="Single icon symbol fills 96-98% of the 1024x1024 canvas (no padding, no inset, no margins). No container, no rounded-square tile, no app plate, no border, no outline, no drop shadow, no outer glow, no bevel, no emboss, no inner shadow. Crisp, sharp, professional composition."

build_prompt() {
    local prompt="$1"
    local size="$2"
    local style="$3"
    local raw="$4"

    if [[ "$raw" == true ]]; then
        echo "$prompt"
        return
    fi

    if [[ -n "$style" ]]; then
        local size_num="${size%%x*}"
        [[ "$size" == "auto" ]] && size_num="1024"

        case $style in
            minimalism)
                echo "Create a ${size_num}x${size_num} minimalist app icon: ${prompt}. ${BASE_RULES} Use clean, simple lines with maximum 2-3 colors. Focus on essential shapes only. White or very light background. Ultra-clean, Apple-inspired minimalism." ;;
            glassy)
                echo "Create a ${size_num}x${size_num} glassy app icon: ${prompt}. ${BASE_RULES} Use glass-like, semi-transparent elements with soft color blending where elements overlap. Subtle gradients and translucent effects. Modern, premium glass aesthetic." ;;
            woven)
                echo "Create a ${size_num}x${size_num} woven/fabric app icon: ${prompt}. ${BASE_RULES} Use textile-inspired patterns with woven textures, soft fabric-like gradients, and organic flowing lines. Warm, tactile materials aesthetic." ;;
            geometric)
                echo "Create a ${size_num}x${size_num} geometric app icon: ${prompt}. ${BASE_RULES} Use only geometric shapes: circles, squares, triangles, hexagons. Bold, angular compositions with high contrast colors. Mathematical precision and symmetry." ;;
            neon)
                echo "Create a ${size_num}x${size_num} neon app icon: ${prompt}. ${BASE_RULES} Use electric neon colors (cyan, magenta, yellow, green) with glowing effects. Dark background with bright neon outlines. Cyberpunk, futuristic aesthetic." ;;
            gradient)
                echo "Create a ${size_num}x${size_num} gradient app icon: ${prompt}. ${BASE_RULES} Use smooth, vibrant gradients as the primary design element. Multiple color transitions creating depth and visual interest. Modern, Instagram-inspired aesthetic." ;;
            flat)
                echo "Create a ${size_num}x${size_num} flat design app icon: ${prompt}. ${BASE_RULES} Use flat design principles: solid colors, no gradients, no shadows, no 3D effects. Clean, modern, Microsoft-inspired flat design." ;;
            material)
                echo "Create a ${size_num}x${size_num} Material Design app icon: ${prompt}. ${BASE_RULES} Use Google Material Design principles: bold colors, geometric shapes, subtle shadows, and depth. Android-optimized design language." ;;
            ios-classic)
                echo "Create a ${size_num}x${size_num} classic iOS app icon: ${prompt}. ${BASE_RULES} Use traditional iOS design: subtle gradients, soft shadows, rounded elements, and Apple's signature color palette. Timeless iOS aesthetic." ;;
            android-material)
                echo "Create a ${size_num}x${size_num} Android Material app icon: ${prompt}. ${BASE_RULES} Use Android Material Design 3: dynamic colors, adaptive icons, geometric shapes, and modern Android styling." ;;
            pixel)
                echo "Create a ${size_num}x${size_num} pixel art app icon: ${prompt}. ${BASE_RULES} Use pixel-perfect, retro 8-bit/16-bit game art style. Sharp, blocky pixels with limited color palette. Nostalgic gaming aesthetic with clear pixel boundaries." ;;
            game)
                echo "Create a ${size_num}x${size_num} gaming app icon: ${prompt}. ${BASE_RULES} Use vibrant, energetic gaming aesthetics with bold colors, dynamic compositions, and playful elements. Modern mobile game icon style with high contrast and engaging visuals." ;;
            clay)
                echo "Create a ${size_num}x${size_num} clay/plasticine app icon: ${prompt}. ${BASE_RULES} Use soft, malleable clay-like textures with organic, handcrafted appearance. Soft shadows, rounded edges, and tactile material feel. Playful, child-friendly aesthetic." ;;
            holographic)
                echo "Create a ${size_num}x${size_num} holographic app icon: ${prompt}. ${BASE_RULES} Use iridescent, rainbow-shifting colors with metallic finishes and prismatic effects. Futuristic, high-tech aesthetic with light refraction and dimensional depth." ;;
            *)
                echo "Unknown style: $style" >&2
                exit 1 ;;
        esac
    else
        echo "Create a full-bleed ${size} px iOS app icon: ${prompt}. Use crisp, minimal design with vibrant colors. Add a subtle inner bevel for gentle depth; no hard shadows or outlines. Center the design with comfortable breathing room from the edges. Solid, light-neutral background. IMPORTANT: Fill the entire canvas edge-to-edge with the design, no padding, no margins. Design elements should be centered with appropriate spacing from edges but the background must cover 100% of the canvas. Add subtle depth with inner highlights, avoid hard shadows. Clean, minimal, Apple-style design. No borders, frames, or rounded corners."
    fi
}

FINAL_PROMPT=$(build_prompt "$PROMPT" "$SIZE" "$STYLE" "$RAW")

generate_openai() {
    local api_key=$(jq -r '.openai_api_key' "$CONFIG_FILE")
    if [[ -z "$api_key" || "$api_key" == "null" ]]; then
        echo "ERROR: openai_api_key not found in config.json"
        exit 1
    fi

    local quality="$QUALITY"
    local num="$NUM"

    if [[ "$MODEL" == "dall-e-3" ]]; then
        [[ "$quality" == "high" || "$quality" == "hd" ]] && quality="hd" || quality="standard"
        num=1
    fi

    local request_json
    if [[ "$MODEL" == "gpt-image-1" ]]; then
        request_json=$(jq -n \
            --arg model "$MODEL" \
            --arg prompt "$FINAL_PROMPT" \
            --arg size "$SIZE" \
            --arg quality "$quality" \
            --arg background "$BACKGROUND" \
            --argjson n "$num" \
            '{model: $model, prompt: $prompt, size: $size, quality: $quality, background: $background, n: $n, output_format: "png"}')
    else
        request_json=$(jq -n \
            --arg model "$MODEL" \
            --arg prompt "$FINAL_PROMPT" \
            --arg size "$SIZE" \
            --arg quality "$quality" \
            --argjson n "$num" \
            '{model: $model, prompt: $prompt, size: $size, quality: $quality, n: $n, response_format: "b64_json"}')

        [[ "$MODEL" == "dall-e-2" ]] && request_json=$(echo "$request_json" | jq 'del(.quality)')
    fi

    echo "Generating icon..."
    echo "Provider: OpenAI"
    echo "Model: $MODEL"
    echo "Style: ${STYLE:-default iOS}"
    echo "Size: $SIZE"

    local response=$(curl -s -X POST "https://api.openai.com/v1/images/generations" \
        -H "Authorization: Bearer $api_key" \
        -H "Content-Type: application/json" \
        -d "$request_json")

    local error=$(echo "$response" | jq -r '.error.message // empty')
    if [[ -n "$error" ]]; then
        echo "ERROR: $error"
        exit 1
    fi

    local count=$(echo "$response" | jq '.data | length')
    for i in $(seq 0 $((count - 1))); do
        local b64=$(echo "$response" | jq -r ".data[$i].b64_json")

        local outfile
        if [[ "$count" -eq 1 ]]; then
            outfile="$OUTPUT"
        else
            local ext="${OUTPUT##*.}"
            local base="${OUTPUT%.*}"
            outfile="${base}_$((i + 1)).${ext}"
        fi

        echo "$b64" | base64 -d > "$outfile"
        echo "Saved: $outfile"
    done
}

generate_gemini() {
    local api_key=$(jq -r '.gemini_api_key' "$CONFIG_FILE")
    if [[ -z "$api_key" || "$api_key" == "null" ]]; then
        echo "ERROR: gemini_api_key not found in config.json"
        exit 1
    fi

    local gemini_model="gemini-3-pro-image-preview"
    [[ "$MODEL" == "gemini-flash" ]] && gemini_model="gemini-2.0-flash-preview-image-generation"

    local request_json=$(jq -n \
        --arg prompt "$FINAL_PROMPT" \
        --arg aspect "$ASPECT_RATIO" \
        '{
            contents: [{parts: [{text: $prompt}]}],
            generationConfig: {
                responseModalities: ["TEXT", "IMAGE"],
                imageConfig: {aspectRatio: $aspect}
            }
        }')

    echo "Generating icon..."
    echo "Provider: Gemini"
    echo "Model: $gemini_model"
    echo "Style: ${STYLE:-default iOS}"
    echo "Aspect Ratio: $ASPECT_RATIO"

    local response=$(curl -s -X POST \
        "https://generativelanguage.googleapis.com/v1beta/models/${gemini_model}:generateContent" \
        -H "x-goog-api-key: $api_key" \
        -H "Content-Type: application/json" \
        -d "$request_json")

    local error=$(echo "$response" | jq -r '.error.message // empty')
    if [[ -n "$error" ]]; then
        echo "ERROR: $error"
        exit 1
    fi

    local img_data=$(echo "$response" | jq -r '.candidates[0].content.parts[] | select(.inlineData) | .inlineData.data // empty')
    if [[ -z "$img_data" ]]; then
        echo "ERROR: No image data in response"
        echo "Response: $response"
        exit 1
    fi

    echo "$img_data" | base64 -d > "$OUTPUT"
    echo "Saved: $OUTPUT"
}

case $MODEL in
    gpt-image-1|dall-e-3|dall-e-2)
        generate_openai ;;
    gemini|gemini-flash)
        generate_gemini ;;
    *)
        echo "Unknown model: $MODEL"
        echo "Supported: gpt-image-1, dall-e-3, dall-e-2, gemini, gemini-flash"
        exit 1 ;;
esac

echo "Done!"
