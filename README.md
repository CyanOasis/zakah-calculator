# Zakah Calculator & Tazkiyah

An intuitive, modern, and highly accurate Zakah calculator built as a cross-platform Flutter application, accompanied by a Cloudflare Workers backend for live metal market rates.

---

## 🤖 OpenAI Codex & GPT-5.6 Collaboration

This project was built during the OpenAI Build Week Hackathon as a co-development project between a human developer and OpenAI Codex & GPT-5.6. 

### 1. How we Collaborated
We used a continuous pair-programming paradigm. The developer defined the requirements, localized aesthetics, and workflow bounds, while Codex generated clean, modular widgets, handled complex state tracking with Provider, and built helper scripts (e.g. for parsing market HTML and maintaining internationalization keys).

### 2. Where Codex Accelerated Our Workflow
*   **Rapid UI Prototyping:** Generating the clean white-and-green list layouts, transaction cards, and the full-screen detailed summary layout matching exact visual specifications.
*   **Custom Bottom Sheet Calendar:** Creating a custom grid-based date picker with preset date range selections (All Time, This Year, Last Year, Custom) completely from scratch in Flutter.
*   **Localization (i18n):** Generating and synchronizing dual-language `.arb` translation keys for English and Bengali.
*   **Cloudflare Worker Backend:** Writing a JavaScript worker to fetch, parse, and cache live gold/silver rates using KV namespaces.

### 3. Key Design & Product Decisions
*   **Grouped History Layout:** Grouped saved records by Month and Year (e.g., `জুলাই ২০২৬`) to make historical scrolling cleaner.
*   **Full-Screen Details View:** Transitioned from a cramped bottom sheet to a dedicated details page to properly visualize Nisab thresholds, total assets, Zakat rate, and itemized asset compositions with specific icons.
*   **Persistent Bottom Navigation Actions:** Swapped the primary persistent actions on the final results step so "Finish/Save" (সম্পন্ন করুন) is always prominently accessible, preventing users from accidentally resetting calculations.

---

## Getting Started & Local Build System

This project features a unified local build system to compile and deploy the Flutter application and Cloudflare Workers backend locally, without relying on GitHub Actions.

### Prerequisites
*   **Flutter SDK:** Installed and added to PATH (the build script will also attempt to auto-detect common installation directories).
*   **Node.js & npm:** Required for deploying the Cloudflare Worker.
*   **Python 3 or Node.js:** Recommended for serving the local web preview.

### Using the Build Script
You can compile and deploy the project using the interactive CLI menu:
```bash
# Start the interactive build menu
build.bat
```
Alternatively, bypass the menu and run actions directly via arguments:
```bash
build.bat apk      # Build Android release APK
build.bat web      # Build Web release bundle
build.bat preview  # Preview Web app locally on http://localhost:8080
build.bat worker   # Deploy the Cloudflare Worker backend
build.bat clean    # Clean flutter cache
```

---

## Cloudflare Workers Backend

This repository includes a Cloudflare Workers backend in `backend/worker.js` to fetch and cache live metal prices.

### Endpoints
*   `GET /health`
*   `GET /api/market/latest?currency=BDT`
*   `GET /api/market/latest?currency=INR`
*   `GET /api/market/latest?currency=TRY`
*   `GET /api/market/latest?currency=USD`

### Deploying the Backend
To deploy or update the Cloudflare Worker locally:
1.  Verify you are logged in to Wrangler:
    ```bash
    npx wrangler login
    ```
2.  Set up your `wrangler.toml` file (e.g. KV namespace ID under `ZAKAH_CACHE`).
3.  Deploy the worker:
    ```bash
    build.bat worker
    ```
    *(Alternatively, run `npx wrangler deploy` from the root directory)*
4.  Configure secrets on Cloudflare if needed:
    ```bash
    npx wrangler secret put HAREM_RAPIDAPI_KEY
    npx wrangler secret put GOLD_API_KEY
    ```
