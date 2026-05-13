<div align="center">

<img src="https://img.shields.io/badge/American_Group_LLC-California,_USA-8b5cf6?style=for-the-badge&labelColor=1e1b4b" alt="American Group LLC — California, USA" />

# American Group LLC

### Health Technology &bull; Software Development &bull; Digital Wellness

[![Website](https://img.shields.io/badge/🌐_Website-americangroupllc.github.io-06b6d4?style=for-the-badge&logoColor=white)](https://americangroupllc.github.io)
[![Facebook](https://img.shields.io/badge/Facebook-AmericanGroupLLC-1877F2?style=for-the-badge&logo=facebook&logoColor=white)](https://www.facebook.com/AmericanGroupLLC)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-american--group--llc-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/company/american-group-llc-california)

---

**California-based technology company creating innovative solutions in health, fitness, and digital wellness that empower people worldwide.**

</div>

---

## 🏢 About Us

**American Group LLC** is a technology company headquartered in **California, USA**, specializing in health technology, mobile app development, and digital wellness solutions. We combine modern software engineering with health science to build products that make a real difference in people's lives.

We believe that **great health technology should be accessible, intuitive, and beautiful**. That's why we build with open-source principles and share our work with the global developer community.

---

## 💼 What We Do

| | Service | Description |
|:---:|---|---|
| ❤️ | **Health & Wellness Apps** | End-to-end development with HealthKit, WorkoutKit & Health Connect |
| 📱 | **Mobile Development** | Native & cross-platform apps for iOS, Android & wearables |
| ☁️ | **Cloud & Backend** | Scalable infrastructure, APIs & real-time data processing |
| 🤖 | **AI & Health Insights** | Sleep analysis, recovery scoring & personalized recommendations |

---

## 🚀 Featured Projects

### ❤️ [MyHealth — Your Personal Fitness OS](https://americangroupllc.github.io/HealthApp/)

A unified **iPhone + Apple Watch** experience that combines training, cardio, nutrition, sleep, and mindfulness into one elegant fitness operating system.

| Module | What It Does |
|---|---|
| 🏋️ **Training** | Smart workout library with personalized plans & progress tracking |
| 🏃 **Running** | GPS tracking with live pace, route maps & race training plans |
| 🍎 **Nutrition** | Barcode scanning, macro tracking & meal planning |
| 💤 **Sleep** | Sleep stage analysis, recovery scoring & smart alarms |
| 🧘 **Mindfulness** | Guided breathing, meditation sessions & Wind Down |
| ⌚ **Apple Watch** | Real-time coaching, complications & always-on display |

> Built with **SwiftUI** • **HealthKit** • **WorkoutKit** • **CloudKit** • **Kotlin** • **React Native**

---

## 💡 Our Values

| | Value | What It Means |
|:---:|---|---|
| 💜 | **Health First** | Technology should make people healthier, happier, and more empowered |
| ⚡ | **Bold Innovation** | Pushing boundaries and challenging assumptions to create breakthroughs |
| 🌍 | **Open & Transparent** | Building in the open, sharing knowledge, and collaborating globally |
| 💪 | **Quality Craft** | Every pixel, every line of code, every interaction matters |

---

## 🛠️ Tech Stack

![Swift](https://img.shields.io/badge/Swift-F05138?style=flat-square&logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-0071E3?style=flat-square&logo=swift&logoColor=white)
![Kotlin](https://img.shields.io/badge/Kotlin-7F52FF?style=flat-square&logo=kotlin&logoColor=white)
![Jetpack Compose](https://img.shields.io/badge/Jetpack_Compose-4285F4?style=flat-square&logo=jetpackcompose&logoColor=white)
![JavaScript](https://img.shields.io/badge/JavaScript-F7DF1E?style=flat-square&logo=javascript&logoColor=black)
![TypeScript](https://img.shields.io/badge/TypeScript-3178C6?style=flat-square&logo=typescript&logoColor=white)
![React Native](https://img.shields.io/badge/React_Native-61DAFB?style=flat-square&logo=react&logoColor=black)
![Node.js](https://img.shields.io/badge/Node.js-339933?style=flat-square&logo=nodedotjs&logoColor=white)
![HTML5](https://img.shields.io/badge/HTML5-E34F26?style=flat-square&logo=html5&logoColor=white)
![CSS3](https://img.shields.io/badge/CSS3-1572B6?style=flat-square&logo=css3&logoColor=white)
![HealthKit](https://img.shields.io/badge/HealthKit-FF2D55?style=flat-square&logo=apple&logoColor=white)
![CloudKit](https://img.shields.io/badge/CloudKit-0071E3?style=flat-square&logo=icloud&logoColor=white)

---

## 🔗 Connect With Us

<div align="center">

| Platform | Link |
|:---:|---|
| 🌐 | [**americangroupllc.github.io**](https://americangroupllc.github.io) |
| 📘 | [**facebook.com/AmericanGroupLLC**](https://www.facebook.com/AmericanGroupLLC) |
| 💼 | [**linkedin.com/company/american-group-llc-california**](https://www.linkedin.com/company/american-group-llc-california) |
| 💻 | [**github.com/AmericanGroupLLC**](https://github.com/AmericanGroupLLC) |

---

⭐ **Star our repos if you find them useful!**

📍 California, USA • Made with ❤️ by **American Group LLC**

</div>

---

## Shared Workflows

This repo provides reusable GitHub Actions workflows that every
product repo's `release.yml` calls at tag time:

- `.github/workflows/release-book.yml` — compiles a styled PDF
  release book from the caller repo's markdown docs (pandoc + XeLaTeX).
- `.github/workflows/release-video.yml` — renders a silent MP4
  screencast of the caller repo's marketing `index.html` (Playwright + ffmpeg).
- `.github/workflows/release-dashboard.yml` — refreshes the
  release dashboard table below.

Product repos call them like:

```yaml
release-book:
  uses: AmericanGroupLLC/AmericanGroupLLC/.github/workflows/release-book.yml@main
  with:
    app-name: ${{ needs.setup.outputs.app-name }}
    version: ${{ needs.setup.outputs.version }}
    brand-color: ${{ needs.setup.outputs.brand-color }}
    docs: ${{ needs.setup.outputs.docs }}
  secrets: inherit
```

Cross-repo `uses:` requires a one-time settings change in this repo
documented in `SECRETS.md` §0.

See also:

- [`SECRETS.md`](SECRETS.md) — every secret consumed and how to set it.
- [`templates/`](templates/) — pandoc + video templates.
- [`scripts/`](scripts/) — local CLI mirrors of the shared workflows
  (handy for dry-runs).


## Connect

- 🌐 Website — <https://americangroupllc.github.io>
- 📺 YouTube — <https://www.youtube.com/@AmericanGroupLLC>
- 💼 LinkedIn — <https://www.linkedin.com/company/american-group-llc-california>
- 👋 Facebook — <https://www.facebook.com/AmericanGroupLLC>
- 🧑‍💻 GitHub — <https://github.com/AmericanGroupLLC>

<!-- DASHBOARD_START -->
<!-- Auto-generated by .github/workflows/release-dashboard.yml. Do not edit. -->

## 📊 Release Dashboard

_Updated: 2026-05-09 08:12 UTC_

| Repository | Latest Release | Published | Notes |
|---|---|---|---|
| [DriftDate](https://github.com/AmericanGroupLLC/DriftDate) | [v1.0.0](https://github.com/AmericanGroupLLC/DriftDate/releases/tag/v1.0.0) | 2026-05-09 | |
| [Offline-AI-Buddy](https://github.com/AmericanGroupLLC/Offline-AI-Buddy) | [v1.0.0](https://github.com/AmericanGroupLLC/Offline-AI-Buddy/releases/tag/v1.0.0) | 2026-05-09 | |
| [HealthApp](https://github.com/AmericanGroupLLC/HealthApp) | [v1.4.0](https://github.com/AmericanGroupLLC/HealthApp/releases/tag/v1.4.0) | 2026-05-09 | |
| [ClockApp](https://github.com/AmericanGroupLLC/ClockApp) | [v1.0.0](https://github.com/AmericanGroupLLC/ClockApp/releases/tag/v1.0.0) | 2026-05-09 | |
| [Card](https://github.com/AmericanGroupLLC/Card) | [v1.0.0](https://github.com/AmericanGroupLLC/Card/releases/tag/v1.0.0) | 2026-05-09 | |
| [BuddyPlay](https://github.com/AmericanGroupLLC/BuddyPlay) | [v1.0.0](https://github.com/AmericanGroupLLC/BuddyPlay/releases/tag/v1.0.0) | 2026-05-09 | |
| [AmericanGroupLLC.github.io](https://github.com/AmericanGroupLLC/AmericanGroupLLC.github.io) | — | — | _no releases yet_ |

<!-- DASHBOARD_END -->
