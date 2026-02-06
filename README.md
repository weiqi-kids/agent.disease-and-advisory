# Disease and Advisory Intelligence System

A Claude CLI-driven multi-agent platform for real-time monitoring and analysis of global health threats through federated data extraction, semantic enrichment, and synthesis.

> **Disclaimer**: This system aggregates publicly available information from official sources. The extracted data and generated reports are for informational purposes only and should not be used as the sole basis for medical, public health, or policy decisions. Always consult official sources and qualified professionals.

---

## System Health Dashboard

**Last Updated:** 2026-02-05

### Layer Status

| Layer | Files | Last Fetch | Status |
|-------|-------|------------|--------|
| ecdc_cdtr | 40 | 2026-02-05 | ✅ |
| tw_cdc_alerts | 30 | 2026-02-05 | ✅ |
| uk_ukhsa_updates | 61 | 2026-02-05 | ✅ |
| us_cdc_han | 0 | 2026-02-05 | ✅ (no active alerts) |
| us_cdc_mmwr | 2004 | 2026-02-05 | ✅ |
| us_travel_health_notices | 18 | 2026-02-05 | ✅ |
| who_disease_outbreak_news | 100 | 2026-02-05 | ✅ |

**Total Extracted Documents:** 2253

### Mode Status

| Mode | Last Report | Status |
|------|-------------|--------|
| weekly_digest | 2026-W06 | ✅ |

---

## Data Sources

| Layer | Source | Type | Coverage |
|-------|--------|------|----------|
| ecdc_cdtr | ECDC Communicable Disease Threats Reports | Atom Feed | Europe |
| tw_cdc_alerts | Taiwan CDC Public Alerts | Atom Feed | Taiwan |
| uk_ukhsa_updates | UK Health Security Agency | Atom Feed | UK |
| us_cdc_han | CDC Health Alert Network | RSS Feed | USA |
| us_cdc_mmwr | CDC MMWR Weekly Reports | RSS Feed | USA |
| us_travel_health_notices | CDC Travel Health Notices | RSS Feed | Global |
| who_disease_outbreak_news | WHO Disease Outbreak News | JSON API | Global |

See `docs/explored.md` for detailed source attribution and evaluation history.

---

## Architecture

```
External Sources (RSS/API)
  → fetch.sh downloads raw data → docs/Extractor/{layer}/raw/*.jsonl
  → Claude extracts (line by line) → docs/Extractor/{layer}/{category}/*.md
  → update.sh writes to Qdrant + checks REVIEW_NEEDED
  → Narrator Mode reads Layer data → docs/Narrator/{mode}/*.md
```

---

## Setup

### Prerequisites

- [Claude CLI](https://docs.anthropic.com/claude-code) installed and authenticated
- Bash 3.2+ (macOS default is compatible)
- `curl`, `jq` installed

### Environment Configuration

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` and fill in your API keys:
   - **Qdrant**: Get credentials from [Qdrant Cloud](https://cloud.qdrant.io)
   - **OpenAI**: Get API key from [OpenAI Platform](https://platform.openai.com/api-keys)

3. Verify the setup:
   ```bash
   source .env && echo "QDRANT_URL=$QDRANT_URL"
   ```

---

## Quick Start

Run the complete workflow:
```bash
claude "執行完整流程"
```

Run specific Layer:
```bash
claude "執行 ecdc_cdtr"
```

Run specific Mode:
```bash
claude "執行 weekly_digest"
```

---

## License

### Code

The source code in this repository is released under the [MIT License](LICENSE).

### Data

The extracted documents in `docs/Extractor/` are aggregated from public sources. Each source retains its original licensing terms:

| Source | License/Terms |
|--------|---------------|
| WHO | [WHO Terms of Use](https://www.who.int/about/policies/terms-of-use) |
| US CDC | Public Domain (US Government Work) |
| ECDC | [ECDC Copyright](https://www.ecdc.europa.eu/en/copyright) |
| UK UKHSA | [Open Government Licence](https://www.nationalarchives.gov.uk/doc/open-government-licence/) |
| Taiwan CDC | Public Information |

### Reports

Reports generated in `docs/Narrator/` are derivative works based on the above sources and are provided for informational purposes only.

---

## Contributing

This project is currently for internal use. Contributions are not accepted at this time.

---

## Acknowledgments

Data sources provided by:
- World Health Organization (WHO)
- US Centers for Disease Control and Prevention (CDC)
- European Centre for Disease Prevention and Control (ECDC)
- UK Health Security Agency (UKHSA)
- Taiwan Centers for Disease Control
