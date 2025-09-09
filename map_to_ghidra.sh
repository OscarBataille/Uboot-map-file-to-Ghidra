#!/bin/bash

# Convert U-Boot system.map file to Ghidra ImportSymbolsScript.py format
# Usage: ./system_map_to_ghidra.sh <input_system.map> [output_file]

if [ $# -lt 1 ]; then
    echo "Usage: $0 <input_system.map> [output_file]"
    echo "Example: $0 system.map symbols_for_ghidra.txt"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="${2:-${INPUT_FILE%.*}_ghidra.txt}"

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' not found!"
    exit 1
fi

echo "Converting $INPUT_FILE to Ghidra ImportSymbolsScript.py format..."

# Create output file
touch "$OUTPUT_FILE"

# Process the system.map file
# Format: ADDRESS TYPE SYMBOL_NAME
while IFS= read -r line; do
    # Skip empty lines and comments
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    
    # Parse the line: address type symbol_name
    if [[ "$line" =~ ^([0-9a-fA-F]+)[[:space:]]+([a-zA-Z])[[:space:]]+(.+)$ ]]; then
        address="${BASH_REMATCH[1]}"
        type="${BASH_REMATCH[2]}"
        symbol="${BASH_REMATCH[3]}"
        
        # Convert address to proper format (add 0x prefix)
        formatted_address="0x${address}"
        
        # Map symbol types to function or label
        # T/t = text/code symbols (functions)
        # Everything else = labels
        case "$type" in
            "T"|"t") 
                ghidra_type="f"  # function
                ;;
            *) 
                ghidra_type="l"  # label (data, bss, etc.)
                ;;
        esac
        
        # Write in Ghidra ImportSymbolsScript.py format: symbol_name address function_or_label
        echo "${symbol} ${formatted_address} ${ghidra_type}" >> "$OUTPUT_FILE"
    fi
done < "$INPUT_FILE"

echo "Conversion complete! Output saved to: $OUTPUT_FILE"
echo ""
echo "To import into Ghidra:"
echo "1. Open your project in Ghidra CodeBrowser"
echo "2. Go to Window -> Script Manager"
echo "3. Search for 'ImportSymbolsScript.py'"
echo "4. Run the script and select your converted file: $OUTPUT_FILE"
echo ""
echo "The script will create:"
echo "  - Functions for symbols with type 'T' or 't' (text/code)"
echo "  - Labels for all other symbol types (data, bss, etc.)"
