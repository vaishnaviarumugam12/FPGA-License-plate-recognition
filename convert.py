from PIL import Image
import numpy as np

# Load image (make sure name matches your file)
img = Image.open("plate.jpg").convert("L").resize((64, 16))

# Convert to array
pixels = np.array(img).flatten()

# Save COE file
with open("plate.coe", "w") as f:
    f.write("memory_initialization_radix=16;\n")
    f.write("memory_initialization_vector=\n")
    f.write(",\n".join(f"{p:02X}" for p in pixels) + ";")

# Preview in terminal
print("Image preview (# = dark, . = light):")
arr = np.array(img)
for row in arr:
    print("".join("#" if p < 128 else "." for p in row))

print("\nDone! plate.coe created.")
print(f"Total pixels: {len(pixels)}")