from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = Path(__file__).parent
SRC = ROOT / "Source"
IPHONE = ROOT / "iPhone-6.5"
IPAD = ROOT / "iPad-13"
SUBS = ROOT / "Subscriptions"

SAGE = "#78927F"
MOSS = "#314B3C"
INK = "#17251D"
IVORY = "#F6F1E7"
CLAY = "#B7775D"
MIST = "#E2E9E2"
WHITE = "#FFFFFF"
FONT_SANS = "C:/Windows/Fonts/segoeui.ttf"
FONT_SANS_BOLD = "C:/Windows/Fonts/seguisb.ttf"
FONT_SERIF = "C:/Windows/Fonts/georgia.ttf"
FONT_SERIF_BOLD = "C:/Windows/Fonts/georgiab.ttf"

SCREENS = [
    ("DAILY PRAYER\n& REFLECTION", "Make space for what matters.", "Today's Practice", "Morning Grounding", ["Stillness · 1 min", "Reading · 2 min", "Prayer · 2 min"], "morning.png"),
    ("MULTI-FAITH\nSPIRITUAL COMPANION", "Your beliefs. Your practice. Your path.", "Your path", "Personalise gently", ["Multiple traditions", "Spiritual / Non-denominational", "Prefer not to specify"], "study.png"),
    ("PRAYER · MEDITATION\n· GRATITUDE", "Build a practice that's truly yours.", "Practice Builder", "Morning Grounding", ["Stillness", "Reading", "Prayer", "Reflection · Optional"], "garden.png"),
    ("PRIVATE SPIRITUAL\nJOURNAL", "Keep meaningful reflections close.", "Journal", "A quiet morning", ["Stored privately on this device", "#gratitude   #reflection", "Search your own words"], "study.png"),
    ("VOICE REFLECTION\n& JOURNALING", "Speak what's on your heart and mind.", "Voice Reflection", "Recording your thought", ["00:42", "Private by default", "Transcription is optional"], "morning.png"),
    ("GUIDED DAILY\nMEDITATION", "Find a quiet moment in your day.", "Stillness", "Let your breathing settle.", ["04:18", "Pause", "No timer is always available"], "garden.png"),
    ("BUILD YOUR\nFAITH ROUTINE", "From two quiet minutes to a complete daily practice.", "Your Practices", "Evening Reflection", ["Breathing · 2 min", "Gratitude · 3 min", "Journaling · Optional"], "study.png"),
    ("REFLECT IN\nYOUR LANGUAGE", "A personal practice that speaks your language.", "Translation", "What would you like to carry forward?", ["Original preserved", "Automatically translated", "Show Original"], "morning.png"),
    ("GENTLE DAILY\nREMINDERS", "Encouragement without pressure.", "Reminders", "A quiet moment is here when you're ready.", ["Weekdays · 8:00 AM", "Pause today", "Edit your wording"], "garden.png"),
    ("YOUR SPIRITUAL\nJOURNEY", "Notice what you keep returning to.", "September", "You made space on 14 days this month.", ["Prayer appeared often", "Short weekday practices", "No streaks. No judgement."], "study.png"),
]

def font(path, size):
    return ImageFont.truetype(path, size)

def cover(path, size):
    im = Image.open(path).convert("RGB")
    sw, sh = im.size
    tw, th = size
    scale = max(tw / sw, th / sh)
    im = im.resize((int(sw * scale), int(sh * scale)), Image.Resampling.LANCZOS)
    left = (im.width - tw) // 2
    top = (im.height - th) // 2
    return im.crop((left, top, left + tw, top + th))

def gradient_overlay(im, top_alpha=210, bottom_alpha=75):
    overlay = Image.new("RGBA", im.size)
    p = overlay.load()
    for y in range(im.height):
        t = y / max(1, im.height - 1)
        a = int(top_alpha * (1 - t) + bottom_alpha * t)
        for x in range(im.width):
            p[x, y] = (20, 43, 30, a)
    return Image.alpha_composite(im.convert("RGBA"), overlay).convert("RGB")

def rounded_mask(size, radius):
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, size[0]-1, size[1]-1), radius=radius, fill=255)
    return mask

def draw_text_fit(draw, xy, text, max_width, font_path, start_size, fill, spacing=8, anchor=None):
    size = start_size
    while size > 20:
        f = font(font_path, size)
        box = draw.multiline_textbbox((0,0), text, font=f, spacing=spacing)
        if box[2] <= max_width:
            draw.multiline_text(xy, text, font=f, fill=fill, spacing=spacing, anchor=anchor)
            return f
        size -= 2
    draw.multiline_text(xy, text, font=font(font_path, size), fill=fill, spacing=spacing, anchor=anchor)

def phone_ui(size, section, title, rows, index):
    w, h = size
    ui = Image.new("RGB", size, IVORY)
    d = ImageDraw.Draw(ui)
    d.rounded_rectangle((0, 0, w-1, h-1), radius=int(w*.09), fill=INK)
    inset = int(w*.028)
    d.rounded_rectangle((inset, inset, w-inset, h-inset), radius=int(w*.075), fill=IVORY)
    d.rounded_rectangle((w*.34, inset+10, w*.66, inset+34), radius=12, fill=INK)
    pad = int(w*.09)
    y = int(h*.10)
    d.text((pad,y), "StillPath", font=font(FONT_SANS_BOLD, int(w*.043)), fill=MOSS)
    y += int(h*.07)
    d.text((pad,y), section, font=font(FONT_SANS_BOLD, int(w*.034)), fill=SAGE)
    y += int(h*.055)
    draw_text_fit(d, (pad,y), title, w-pad*2, FONT_SERIF_BOLD, int(w*.070), INK, spacing=5)
    y += int(h*.15)
    if index == 5:
        d.ellipse((w*.34,y,w*.66,y+w*.32), fill=SAGE)
        d.text((w/2,y+w*.16), rows[0], font=font(FONT_SANS_BOLD,int(w*.058)), fill=WHITE, anchor="mm")
        y += int(h*.38)
        d.text((w/2,y), "Ⅱ", font=font(FONT_SANS_BOLD,int(w*.08)), fill=MOSS, anchor="mm")
        y += int(h*.08)
        rows = rows[2:]
    elif index == 4:
        d.rounded_rectangle((pad,y,w-pad,y+int(h*.17)),radius=30,fill="#FDEDE7")
        d.text((w/2,y+int(h*.05)), "●  LIVE", font=font(FONT_SANS_BOLD,int(w*.032)), fill=CLAY, anchor="mm")
        d.text((w/2,y+int(h*.12)), rows[0], font=font(FONT_SANS_BOLD,int(w*.07)), fill=INK, anchor="mm")
        y += int(h*.21)
        rows = rows[1:]
    for j, row in enumerate(rows):
        rh = int(h*.095)
        d.rounded_rectangle((pad,y,w-pad,y+rh),radius=28,fill=WHITE,outline=MIST,width=3)
        d.ellipse((pad+22,y+rh*.35,pad+42,y+rh*.35+20),fill=SAGE if j%2==0 else CLAY)
        draw_text_fit(d,(pad+58,y+rh*.50),row,w-pad*2-75,FONT_SANS, int(w*.035),INK,anchor="lm")
        y += rh + int(h*.018)
    by = h-int(h*.13)
    d.rounded_rectangle((pad,by,w-pad,by+int(h*.075)),radius=32,fill=MOSS)
    d.text((w/2,by+int(h*.038)), "Begin Practice" if index not in (3,4,7,8,9) else "Continue", font=font(FONT_SANS_BOLD,int(w*.034)),fill=WHITE,anchor="mm")
    return ui

def render_marketing(size, outdir, label):
    outdir.mkdir(parents=True, exist_ok=True)
    w,h=size
    for i,(headline,support,section,title,rows,bg) in enumerate(SCREENS,1):
        canvas = gradient_overlay(cover(SRC/bg,size), 225, 105)
        d=ImageDraw.Draw(canvas)
        margin=int(w*.075)
        y=int(h*.055)
        d.text((margin,y), "STILLPATH",font=font(FONT_SANS_BOLD,int(w*.035)),fill="#D9E7DB")
        y+=int(h*.055)
        draw_text_fit(d,(margin,y),headline,w-margin*2,FONT_SANS_BOLD,int(w*.078 if label=="iphone" else w*.054),WHITE,spacing=int(w*.010))
        y+=int(h*.15)
        draw_text_fit(d,(margin,y),support,w-margin*2,FONT_SERIF,int(w*.041 if label=="iphone" else w*.031),WHITE,spacing=6)
        if label=="iphone":
            pw,ph=int(w*.70),int(h*.60)
            px,py=(w-pw)//2,int(h*.37)
        else:
            pw,ph=int(w*.54),int(h*.66)
            px,py=int(w*.40),int(h*.30)
        ui=phone_ui((pw,ph),section,title,rows,i-1)
        shadow=Image.new("RGBA",(pw+70,ph+70),(0,0,0,0))
        ImageDraw.Draw(shadow).rounded_rectangle((35,35,pw+35,ph+35),radius=int(pw*.09),fill=(0,0,0,100))
        shadow=shadow.filter(ImageFilter.GaussianBlur(24))
        canvas.paste(shadow,(px-35,py-20),shadow)
        canvas.paste(ui,(px,py),rounded_mask((pw,ph),int(pw*.09)))
        canvas.save(outdir/f"{i:02d}-{headline.splitlines()[0].lower().replace(' ','-').replace('·','and')}.png",quality=95)

def render_subscription_assets():
    SUBS.mkdir(parents=True,exist_ok=True)
    # Square promotional image without pricing or tiny text.
    size=(1024,1024)
    bg=gradient_overlay(cover(SRC/"morning.png",size),215,120)
    d=ImageDraw.Draw(bg)
    d.text((72,70),"STILLPATH PREMIUM",font=font(FONT_SANS_BOLD,42),fill="#D9E7DB")
    draw_text_fit(d,(72,145),"MAKE YOUR\nPRACTICE\nTRULY YOURS",880,FONT_SANS_BOLD,86,WHITE,spacing=8)
    d.rounded_rectangle((70,650,954,935),radius=42,fill=(246,241,231))
    features=["Voice reflections","Translation","Advanced search","Private insights"]
    for j,t in enumerate(features):
        x=115+(j%2)*430; y=710+(j//2)*100
        d.ellipse((x,y,x+28,y+28),fill=SAGE)
        d.text((x+48,y-4),t,font=font(FONT_SANS_BOLD,30),fill=INK)
    bg.save(SUBS/"premium-promotional-1024.png")
    # Review screenshot showing the complete paywall and transparent pricing.
    w,h=1290,2796
    img=Image.new("RGB",(w,h),IVORY); d=ImageDraw.Draw(img)
    d.rectangle((0,0,w,520),fill=MOSS)
    d.text((w/2,130),"STILLPATH PREMIUM",font=font(FONT_SANS_BOLD,45),fill="#D9E7DB",anchor="mm")
    d.multiline_text((w/2,275),"Make your practice\ntruly yours.",font=font(FONT_SERIF_BOLD,82),fill=WHITE,anchor="mm",align="center",spacing=18)
    features=["Unlimited routines","Voice reflections & audio journal","Translation and advanced search","Private insights and optional AI","Expanded widgets, sync and export"]
    y=650
    for t in features:
        d.rounded_rectangle((90,y,1200,y+155),radius=38,fill=WHITE,outline=MIST,width=4)
        d.ellipse((135,y+56,178,y+99),fill=SAGE)
        d.text((215,y+77),t,font=font(FONT_SANS_BOLD,39),fill=INK,anchor="lm")
        y+=185
    d.rounded_rectangle((90,1640,1200,1905),radius=46,fill=WHITE,outline=SAGE,width=6)
    d.text((145,1710),"Monthly",font=font(FONT_SANS_BOLD,46),fill=INK)
    d.text((1140,1710),"£4.99 / month",font=font(FONT_SANS_BOLD,39),fill=MOSS,anchor="ra")
    d.text((145,1790),"7-day free trial",font=font(FONT_SANS,34),fill=SAGE)
    d.rounded_rectangle((90,1940,1200,2235),radius=46,fill=MOSS)
    d.text((145,2010),"Annual",font=font(FONT_SANS_BOLD,46),fill=WHITE)
    d.text((1140,2010),"£39.99 / year",font=font(FONT_SANS_BOLD,39),fill=WHITE,anchor="ra")
    d.text((145,2090),"7-day free trial · Best value",font=font(FONT_SANS,34),fill="#D9E7DB")
    d.rounded_rectangle((90,2300,1200,2425),radius=60,fill=CLAY)
    d.text((w/2,2363),"Continue",font=font(FONT_SANS_BOLD,43),fill=WHITE,anchor="mm")
    d.text((w/2,2505),"Restore Purchases",font=font(FONT_SANS_BOLD,32),fill=MOSS,anchor="mm")
    d.multiline_text((w/2,2610),"Subscriptions renew automatically unless cancelled.\nJournal entries remain accessible if Premium expires.",font=font(FONT_SANS,27),fill="#536058",anchor="mm",align="center",spacing=8)
    img.save(SUBS/"premium-review-1290x2796.png")

if __name__ == "__main__":
    render_marketing((1284,2778),IPHONE,"iphone")
    render_marketing((2064,2752),IPAD,"ipad")
    render_subscription_assets()
    print("Rendered 22 App Store assets")
