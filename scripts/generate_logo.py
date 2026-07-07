from PIL import Image, ImageDraw, ImageFont
import os

os.makedirs('assets', exist_ok=True)
size = 1024
bg = (15,23,36)
accent = (255,45,149)
accent2 = (0,255,209)

img = Image.new('RGBA', (size, size), bg)
d = ImageDraw.Draw(img)

# draw circle
cx, cy = size//2, int(size*0.30)
r = int(size*0.195)
d.ellipse([cx-r, cy-r, cx+r, cy+r], fill=accent)

# draw arc (accent2)
for i in range(6):
    d.arc([size*0.25, size*0.45, size*0.75, size*0.75], start=180+i*6, end=220+i*6, fill=accent2, width=28)

# text
try:
    font_bold = ImageFont.truetype('Arial.ttf', 96)
except Exception:
    font_bold = ImageFont.load_default()

text1 = 'SHUTTLE'
text2 = 'SUMMARY'
bbox1 = d.textbbox((0,0), text1, font=font_bold)
bbox2 = d.textbbox((0,0), text2, font=font_bold)
w1 = bbox1[2] - bbox1[0]
h1 = bbox1[3] - bbox1[1]
w2 = bbox2[2] - bbox2[0]
h2 = bbox2[3] - bbox2[1]

d.text(((size-w1)/2, int(size*0.74)), text1, font=font_bold, fill=(255,255,255))
d.text(((size-w2)/2, int(size*0.82)), text2, font=font_bold, fill=(255,255,255))

img.save('assets/logo.png')
print('Wrote assets/logo.png')
