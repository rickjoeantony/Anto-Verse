import sys
import os
from rembg import remove
from PIL import Image

input_path = "C:\\Users\\rickj\\TS_RJ\\solo_leveling_tracker\\frontend\\public\\shadow_monarch.png"
output_path = "C:\\Users\\rickj\\TS_RJ\\solo_leveling_tracker\\frontend\\public\\shadow_monarch.png" # Overwrite

try:
    print(f"Opening {input_path}...")
    input_image = Image.open(input_path)
    
    print("Removing background...")
    output_image = remove(input_image)
    
    print(f"Saving to {output_path}...")
    output_image.save(output_path)
    print("Success!")
except Exception as e:
    print(f"Error: {e}")
    sys.exit(1)
