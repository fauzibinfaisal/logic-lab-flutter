from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.enums import TA_LEFT, TA_RIGHT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.platypus import (
    KeepTogether,
    PageBreak,
    Paragraph,
    SimpleDocTemplate,
    Spacer,
    Table,
    TableStyle,
)


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "output" / "pdf" / "Fauzi-CV.pdf"

NAVY = colors.HexColor("#080D1A")
INK = colors.HexColor("#172033")
MUTED = colors.HexColor("#536079")
CYAN = colors.HexColor("#008BAD")
PALE = colors.HexColor("#EAF8FC")
LINE = colors.HexColor("#D7E1EA")


def build_styles():
    base = getSampleStyleSheet()
    return {
        "name": ParagraphStyle(
            "Name",
            parent=base["Title"],
            fontName="Helvetica-Bold",
            fontSize=27,
            leading=30,
            textColor=colors.white,
            spaceAfter=3,
        ),
        "role": ParagraphStyle(
            "Role",
            parent=base["Normal"],
            fontName="Helvetica",
            fontSize=11,
            leading=15,
            textColor=colors.HexColor("#A9EFFF"),
        ),
        "contact": ParagraphStyle(
            "Contact",
            parent=base["Normal"],
            fontName="Helvetica",
            fontSize=8.6,
            leading=12,
            textColor=colors.HexColor("#DCE5F3"),
        ),
        "section": ParagraphStyle(
            "Section",
            parent=base["Heading2"],
            fontName="Helvetica-Bold",
            fontSize=11,
            leading=14,
            textColor=CYAN,
            spaceBefore=6,
            spaceAfter=6,
            uppercase=True,
        ),
        "body": ParagraphStyle(
            "Body",
            parent=base["BodyText"],
            fontName="Helvetica",
            fontSize=9,
            leading=13,
            textColor=INK,
            spaceAfter=5,
        ),
        "job": ParagraphStyle(
            "Job",
            parent=base["Heading3"],
            fontName="Helvetica-Bold",
            fontSize=10,
            leading=13,
            textColor=INK,
            spaceAfter=1,
        ),
        "meta": ParagraphStyle(
            "Meta",
            parent=base["Normal"],
            fontName="Helvetica-Oblique",
            fontSize=8.2,
            leading=11,
            textColor=MUTED,
            alignment=TA_RIGHT,
        ),
        "bullet": ParagraphStyle(
            "Bullet",
            parent=base["BodyText"],
            fontName="Helvetica",
            fontSize=8.5,
            leading=12,
            textColor=INK,
            leftIndent=10,
            firstLineIndent=-7,
            bulletIndent=0,
            spaceAfter=2,
        ),
        "skill": ParagraphStyle(
            "Skill",
            parent=base["BodyText"],
            fontName="Helvetica",
            fontSize=8.3,
            leading=11.5,
            textColor=INK,
        ),
        "small": ParagraphStyle(
            "Small",
            parent=base["BodyText"],
            fontName="Helvetica",
            fontSize=7.8,
            leading=11,
            textColor=MUTED,
        ),
    }


def section_title(text, styles):
    return [Paragraph(text.upper(), styles["section"]), rule()]


def rule():
    line = Table([[""]], colWidths=[174 * mm], rowHeights=[0.35])
    line.setStyle(TableStyle([("BACKGROUND", (0, 0), (-1, -1), LINE)]))
    return line


def bullet(text, styles):
    return Paragraph(f"- {text}", styles["bullet"])


def job(title, company, location, period, bullets, styles):
    heading = Table(
        [[Paragraph(f"{title}<br/><font color='#008BAD'>{company}</font>", styles["job"]),
          Paragraph(f"{period}<br/>{location}", styles["meta"])]],
        colWidths=[123 * mm, 51 * mm],
    )
    heading.setStyle(TableStyle([
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("LEFTPADDING", (0, 0), (-1, -1), 0),
        ("RIGHTPADDING", (0, 0), (-1, -1), 0),
        ("TOPPADDING", (0, 0), (-1, -1), 0),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 3),
    ]))
    return KeepTogether([heading, *[bullet(item, styles) for item in bullets], Spacer(1, 3)])


def draw_page(canvas, doc):
    canvas.saveState()
    width, height = A4
    if doc.page == 1:
        canvas.setFillColor(NAVY)
        canvas.rect(0, height - 50 * mm, width, 50 * mm, fill=1, stroke=0)
    canvas.setStrokeColor(LINE)
    canvas.line(18 * mm, 13 * mm, width - 18 * mm, 13 * mm)
    canvas.setFont("Helvetica", 7.5)
    canvas.setFillColor(MUTED)
    canvas.drawString(18 * mm, 8.5 * mm, "Fauzi - Senior Mobile Engineer")
    canvas.drawRightString(width - 18 * mm, 8.5 * mm, f"Page {doc.page}")
    canvas.restoreState()


def build_cv():
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    styles = build_styles()
    doc = SimpleDocTemplate(
        str(OUTPUT),
        pagesize=A4,
        rightMargin=18 * mm,
        leftMargin=18 * mm,
        topMargin=17 * mm,
        bottomMargin=18 * mm,
        title="Fauzi - Senior Mobile Engineer CV",
        author="Fauzi",
        subject="Senior Mobile Engineer specializing in iOS, Flutter, IoT, and BLE",
    )

    story = [
        Table(
            [[
                Paragraph("Fauzi", styles["name"]),
                Paragraph(
                    "Jakarta, Indonesia<br/>"
                    "+62 858 9040 6101<br/>"
                    "<link href='mailto:fauzibinfaisal@gmail.com' color='#A9EFFF'>"
                    "fauzibinfaisal@gmail.com</link>",
                    styles["contact"],
                ),
            ], [
                Paragraph(
                    "Senior Mobile Engineer | iOS, Flutter, IoT &amp; BLE",
                    styles["role"],
                ),
                Paragraph(
                    "<link href='https://linkedin.com/in/fauzibinfaisal' color='#A9EFFF'>LinkedIn</link>"
                    "  |  "
                    "<link href='https://github.com/fauzibinfaisal' color='#A9EFFF'>GitHub</link>",
                    styles["contact"],
                ),
            ]],
            colWidths=[113 * mm, 61 * mm],
        ),
        Spacer(1, 14 * mm),
        *section_title("Professional Summary", styles),
        Spacer(1, 4),
        Paragraph(
            "Senior Mobile Engineer with 7+ years of experience building production iOS and "
            "cross-platform applications using Swift, Flutter, and Kotlin. Strong expertise in "
            "Bluetooth Low Energy and IoT integrations, modular mobile architecture, real-time "
            "systems, and end-to-end product delivery across POS, healthcare, F&amp;B, and connected devices.",
            styles["body"],
        ),
        Spacer(1, 3),
        *section_title("Core Expertise", styles),
        Spacer(1, 5),
        Table(
            [[
                Paragraph("<b>Mobile</b><br/>Swift, Objective-C, UIKit, SwiftUI, Combine, Flutter, Dart, Kotlin, Java", styles["skill"]),
                Paragraph("<b>Architecture</b><br/>MVVM, Clean Architecture, VIPER, modularization, TDD, code review", styles["skill"]),
            ], [
                Paragraph("<b>Connected Apps</b><br/>BLE, IoT SDKs, REST APIs, WebSocket, JSON, OAuth", styles["skill"]),
                Paragraph("<b>Delivery</b><br/>GitHub Actions, GitLab CI, Fastlane, TestFlight, App Store Connect", styles["skill"]),
            ]],
            colWidths=[87 * mm, 87 * mm],
            rowHeights=[None, None],
            style=TableStyle([
                ("BACKGROUND", (0, 0), (-1, -1), PALE),
                ("BOX", (0, 0), (-1, -1), 0.5, LINE),
                ("INNERGRID", (0, 0), (-1, -1), 0.5, colors.white),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("LEFTPADDING", (0, 0), (-1, -1), 8),
                ("RIGHTPADDING", (0, 0), (-1, -1), 8),
                ("TOPPADDING", (0, 0), (-1, -1), 7),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 7),
            ]),
        ),
        Spacer(1, 6),
        *section_title("Professional Experience", styles),
        Spacer(1, 5),
        job(
            "Senior Mobile Engineer (iOS / Flutter)",
            "Butterfly Global Pte Ltd",
            "Singapore",
            "Nov 2023 - Apr 2026",
            [
                "Owned and scaled an iOS POS system for real-time, multi-device restaurant operations.",
                "Refactored legacy code into modular UIKit and MVVM architecture, improving load time by 40-60%.",
                "Improved API and WebSocket performance, reducing synchronization latency by 20-30%.",
                "Managed production releases and partnered with backend, product, and design teams end to end.",
            ],
            styles,
        ),
        job(
            "Flutter Lead Engineer (IoT)",
            "SEI Asia Sdn Bhd",
            "Malaysia - Freelance",
            "Dec 2025 - Mar 2026",
            [
                "Led a Flutter IoT application integrating smart watches and smart door locks over BLE and Wi-Fi.",
                "Collaborated with hardware teams in Shenzhen to build, test, and integrate device SDKs.",
                "Improved debugging efficiency by 2-3x and refactored legacy code into maintainable modules.",
            ],
            styles,
        ),
        job(
            "Mobile Application Developer (IoT)",
            "PT Karadigital Solusi Indonesia",
            "Indonesia",
            "May 2023 - Nov 2023",
            [
                "Developed BLE modules in Swift, Objective-C, Kotlin, and Java for watches and fitness devices.",
                "Improved BLE connection stability by approximately 25-35% and bridged native iOS modules to React Native.",
            ],
            styles,
        ),
        PageBreak(),
        *section_title("Professional Experience - Continued", styles),
        Spacer(1, 5),
        job(
            "iOS Developer",
            "PT Sehat Digital Nusantara (AlteaCare)",
            "Indonesia",
            "Feb 2022 - Feb 2023",
            [
                "Built a centralized analytics layer and scalable AppsFlyer deep-linking system.",
                "Improved maintainability and monitored production quality with Crashlytics and Instruments.",
            ],
            styles,
        ),
        job(
            "Mobile Application Developer (iOS / Flutter)",
            "PT Infotech Solutions",
            "Indonesia",
            "Feb 2021 - Feb 2022",
            [
                "Delivered production Swift, SwiftUI, Combine, UIKit, and Flutter applications for international clients.",
                "Built REST integrations and applied scalable architecture from initial development through store releases.",
            ],
            styles,
        ),
        job(
            "iOS Developer",
            "PT Buana Varia Komputama - Kimia Farma",
            "Indonesia",
            "Feb 2020 - Feb 2021",
            [
                "Led healthcare features including OCR prescription and Indonesian ID card scanning.",
                "Reduced manual input by 40-50% and improved onboarding efficiency by approximately 30%.",
            ],
            styles,
        ),
        job(
            "Android Developer",
            "PT Infolab Digital Solutions",
            "Indonesia",
            "Jan 2018 - Jan 2020",
            [
                "Developed Android applications in Java and Kotlin, including the Undangin event platform.",
                "Worked with design and backend teams from concept through testing and production delivery.",
            ],
            styles,
        ),
        Spacer(1, 4),
        *section_title("Education", styles),
        Spacer(1, 5),
        job(
            "World Class Developer Program",
            "Apple Developer Academy @ BINUS",
            "Indonesia",
            "2019 - 2020",
            ["Competitive full-scholarship program focused on iOS product development and App Store delivery."],
            styles,
        ),
        job(
            "Bachelor of Computer Science - Cum Laude",
            "Universitas Bengkulu",
            "Indonesia",
            "2010 - 2015",
            ["GPA 3.52 / 4.00; HIMATIF division coordinator."],
            styles,
        ),
        Spacer(1, 3),
        *section_title("Selected Impact & Projects", styles),
        Spacer(1, 5),
        Table(
            [[
                Paragraph("<b>Impact</b><br/>60% faster load time<br/>20-30% lower sync latency<br/>100k+ product users<br/>Best Paper award", styles["small"]),
                Paragraph("<b>Selected products</b><br/>Butterfly POS and BYOD<br/>Pininfarina Hybrid Watch<br/>Starbucks Card iOS<br/>Kimia Farma iOS<br/>HIA Lifeline and Hygear", styles["small"]),
            ]],
            colWidths=[87 * mm, 87 * mm],
            style=TableStyle([
                ("BACKGROUND", (0, 0), (-1, -1), PALE),
                ("BOX", (0, 0), (-1, -1), 0.5, LINE),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("LEFTPADDING", (0, 0), (-1, -1), 9),
                ("RIGHTPADDING", (0, 0), (-1, -1), 9),
                ("TOPPADDING", (0, 0), (-1, -1), 8),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 8),
            ]),
        ),
    ]

    doc.build(story, onFirstPage=draw_page, onLaterPages=draw_page)


if __name__ == "__main__":
    build_cv()
