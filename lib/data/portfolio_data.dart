// ---------------------------------------------------------------------------
// Portfolio Data — Single source of truth for all CV content
// ---------------------------------------------------------------------------

class ContactInfo {
  final String phone;
  final String email;
  final String location;
  const ContactInfo({
    required this.phone,
    required this.email,
    required this.location,
  });
}

class Experience {
  final String title;
  final String company;
  final String location;
  final String period;
  final List<String> bullets;
  const Experience({
    required this.title,
    required this.company,
    required this.location,
    required this.period,
    required this.bullets,
  });
}

class Education {
  final String institution;
  final String degree;
  final String period;
  final List<String> bullets;
  const Education({
    required this.institution,
    required this.degree,
    required this.period,
    required this.bullets,
  });
}

class SkillGroup {
  final String category;
  final List<String> skills;
  const SkillGroup({required this.category, required this.skills});
}

class Achievement {
  final String emoji;
  final String metric;
  final String description;
  const Achievement({
    required this.emoji,
    required this.metric,
    required this.description,
  });
}

// ---------------------------------------------------------------------------
// Data
// ---------------------------------------------------------------------------

const kContact = ContactInfo(
  phone: '+62 858 9040 6101',
  email: 'fauzibinfaisal@gmail.com',
  location: 'Jakarta, Indonesia',
);

const kAbout =
    'Senior Mobile Application Engineer with 7+ years of experience building iOS and cross-platform applications using Swift, Flutter, and Kotlin. Strong expertise in IoT and Bluetooth Low Energy (BLE) integration. Experienced across POS, healthcare, F&B, and IoT domains.';

const kExperiences = [
  Experience(
    title: 'Senior Mobile Engineer (iOS / Flutter)',
    company: 'Butterfly Global Pte Ltd',
    location: 'Singapore',
    period: 'Nov 2023 – Apr 2026',
    bullets: [
      'Owned and scaled an iOS-based POS system used in real-time, multi-device environments.',
      'Refactored legacy codebase into modular UIKit + MVVM architecture, improving load time by 40–60%.',
      'Improved API and WebSocket performance, reducing sync latency by 20–30%.',
      'Managed production releases and stability improvements across multiple deployments.',
      'Collaborated with backend, product, and design teams to deliver features end-to-end.',
    ],
  ),
  Experience(
    title: 'Flutter Lead Engineer (IoT – Smart Watch & Smart Door Lock)',
    company: 'SEI Asia Sdn Bhd',
    location: 'Malaysia (Freelance)',
    period: 'Dec 2025 – Mar 2026',
    bullets: [
      'Led development of IoT mobile application with BLE and Wi-Fi device integration.',
      'Collaborated directly with hardware teams in Shenzhen to build, test, and integrate SDKs.',
      'Improved debugging efficiency, reducing issue resolution time by 2–3×.',
      'Refactored legacy code into a modular structure, improving maintainability.',
    ],
  ),
  Experience(
    title: 'Mobile Application Developer (IoT – Smart Watch & Fitness Gears)',
    company: 'PT Karadigital Solusi Indonesia',
    location: 'Indonesia',
    period: 'May 2023 – Nov 2023',
    bullets: [
      'Developed native BLE modules using Swift, Objective-C, Kotlin, and Java.',
      'Improved BLE connection stability by approximately 25–35%.',
      'Bridged native iOS modules with React Native for advanced BLE operations.',
      'Collaborated with hardware, backend, and product teams.',
    ],
  ),
  Experience(
    title: 'iOS Developer (Healthcare iOS App)',
    company: 'PT Sehat Digital Nusantara',
    location: 'Indonesia',
    period: 'Feb 2022 – Feb 2023',
    bullets: [
      'Built a centralized analytics tracking layer, reducing duplication and improving consistency.',
      'Designed a scalable deep-linking system using AppsFlyer.',
      'Reduced navigation bugs and improved maintainability through DRY architecture.',
      'Monitored and improved application performance using Crashlytics and Instruments.',
    ],
  ),
  Experience(
    title: 'Mobile Application Developer (Swift iOS & Flutter, Android)',
    company: 'PT Infotech Solutions',
    location: 'Indonesia',
    period: 'Feb 2021 – Feb 2022',
    bullets: [
      'Delivered production iOS applications using Swift, SwiftUI, Combine, and UIKit.',
      'Built and integrated mobile applications with REST APIs for international clients.',
      'Developed Flutter applications from scratch and deployed to production.',
      'Applied scalable architecture patterns for maintainability and testability.',
    ],
  ),
  Experience(
    title: 'iOS Developer (Healthcare – Kimia Farma)',
    company: 'PT Buana Varia Komputama',
    location: 'Indonesia',
    period: 'Feb 2020 – Feb 2021',
    bullets: [
      'Led development of healthcare features for the Kimia Farma mobile platform.',
      'Implemented OCR prescription scanning, reducing manual input by 40–50%.',
      'Built a custom camera module, improving scan accuracy and user experience.',
      'Integrated Indonesian ID card (KTP) scanning, improving onboarding efficiency by ~30%.',
    ],
  ),
  Experience(
    title: 'Android Developer (Java & Kotlin)',
    company: 'PT Infolab Digital Solutions',
    location: 'Indonesia',
    period: 'Jan 2018 – Jan 2020',
    bullets: [
      'Developed Android applications using Java and Kotlin.',
      'Built Undangin, an event management application.',
      'Collaborated with design and backend teams from concept to production release.',
      'Ensured application stability through testing and debugging.',
    ],
  ),
];

const kSkillGroups = [
  SkillGroup(
    category: 'Languages & Frameworks',
    skills: [
      'Swift', 'Objective-C', 'Dart', 'Kotlin', 'Java',
      'UIKit', 'SwiftUI', 'Combine', 'Flutter', 'RxSwift',
    ],
  ),
  SkillGroup(
    category: 'Architecture & Practices',
    skills: [
      'MVVM', 'Clean Architecture', 'VIPER', 'Modularization',
      'TDD', 'Code Reviews', 'Agile / Scrum',
    ],
  ),
  SkillGroup(
    category: 'Backend Integration',
    skills: ['REST APIs', 'WebSocket', 'JSON', 'OAuth'],
  ),
  SkillGroup(
    category: 'iOS Platform & Security',
    skills: [
      'Core Data', 'Keychain', 'Biometrics', 'APNs',
      'Secure Storage', 'Encryption & Decryption',
    ],
  ),
  SkillGroup(
    category: 'Monitoring & Analytics',
    skills: [
      'Firebase Analytics', 'Crashlytics', 'Remote Config',
      'Sentry', 'APM', 'Crash Analysis',
    ],
  ),
  SkillGroup(
    category: 'CI/CD & DevOps',
    skills: [
      'GitHub Actions', 'GitLab CI', 'Fastlane',
      'TestFlight', 'App Store Connect', 'Google Play Console',
    ],
  ),
  SkillGroup(
    category: 'Tools & Platforms',
    skills: [
      'Xcode', 'Android Studio', 'VS Code', 'Instruments',
      'Figma', 'Postman', 'Jira', 'GitHub', 'CocoaPods', 'SPM',
    ],
  ),
];

const kAchievements = [
  Achievement(
    emoji: '⚡',
    metric: '60%',
    description: 'Improved load time via modular architecture refactoring',
  ),
  Achievement(
    emoji: '🔄',
    metric: '20–30%',
    description: 'Reduced API & real-time sync latency in POS systems',
  ),
  Achievement(
    emoji: '📦',
    metric: '30%',
    description: 'Decreased app size through data & state optimization',
  ),
  Achievement(
    emoji: '🏥',
    metric: '50%',
    description: 'Reduced manual input via OCR prescription scanning',
  ),
  Achievement(
    emoji: '👥',
    metric: '100k+',
    description: 'Users across POS, healthcare, and IoT products',
  ),
  Achievement(
    emoji: '🍎',
    metric: 'Top 2k',
    description: 'Selected for Apple Developer Academy (1 of ~2,000 applicants)',
  ),
  Achievement(
    emoji: '🏆',
    metric: 'Best Paper',
    description: 'Award at INACIT International Conference, Jakarta',
  ),
];

const kEducations = [
  Education(
    institution: 'Apple Developer Academy @ BINUS',
    degree: 'World Class Developer Program',
    period: '2019 – 2020',
    bullets: [
      'Competitive full-scholarship program.',
      'iOS fundamentals: UIKit, HIG, App Lifecycle, Core Data, Core Motion.',
      'App Store deployment and TestFlight distribution experience.',
    ],
  ),
  Education(
    institution: 'Universitas Bengkulu',
    degree: 'Bachelor of Computer Science (Informatics Engineering)',
    period: '2010 – 2015',
    bullets: [
      'GPA: 3.52 / 4.00 — Cum Laude.',
      'HIMATIF Division Coordinator (Informatics Engineering Student Association).',
    ],
  ),
];

const kProjects = [
  'Pininfarina Hybrid Watch (Android & iOS)',
  'HIA Lifeline (Android & iOS)',
  'Butterfly POS',
  'Butterfly BYOD Web App',
  'Starbucks Card (iOS)',
  'IndoIndians (Android & iOS)',
  'EXAIIMS (Android & iOS)',
  'KYAH (Android & iOS)',
  'Kimia Farma (iOS)',
  'Lifeline (Android & iOS)',
  'Hygear (Android & iOS)',
  'MIKA (iOS)',
  'Undangin (Android)',
];
