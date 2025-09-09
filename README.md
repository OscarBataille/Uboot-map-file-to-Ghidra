# Uboot System.map -> Ghidra's ImportSymbolsScript.py

This script allows importing Uboot's symbols into Ghidra.

## How to use

1. Execute the script on the U-boot System.map file
```bash
 bash map_to_ghidra.sh test/System.map output.csv
```

2. Import output.csv in Ghidra with the ImportSymbolsScript.py
