#!/bin/bash
# Script to add SEO frontmatter to case_series extraction results
# This script adds JSON-LD Schema and YMYL frontmatter to all case_series/*.md files

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CASE_SERIES_DIR="$PROJECT_ROOT/docs/Extractor/us_cdc_mmwr/case_series"

# Base URLs for EpiAlert
SITE_URL="https://epialert.weiqi.kids"
ORG_ID="${SITE_URL}#organization"
PERSON_ID="${SITE_URL}/about#person"

# YMYL disclaimer for health content
YMYL_DISCLAIMER="本站內容由 AI 自動彙整自 WHO、CDC 等官方來源,僅供參考,不構成醫療建議。如有健康疑慮,請諮詢專業醫療人員。"

# Counter
PROCESSED=0

# Find all .md files in 2025/ and 2026/ subdirectories, excluding index.md
find "$CASE_SERIES_DIR" -type f -name "*.md" ! -name "index.md" | grep -E "(2025|2026)/" | sort | while read -r file; do
    # Skip if file already has seo frontmatter
    if grep -q "^seo:" "$file"; then
        echo "Skipping (already has SEO): $file"
        continue
    fi

    # Extract metadata from existing frontmatter
    TITLE=$(sed -n 's/^title: "\(.*\)"$/\1/p' "$file" | head -1)
    SOURCE_URL=$(sed -n 's/^source_url: "\(.*\)"$/\1/p' "$file" | head -1)
    DATE=$(sed -n 's/^date: \(.*\)$/\1/p' "$file" | head -1)

    # Generate canonical URL from file path
    # Example: /docs/Extractor/us_cdc_mmwr/case_series/2026/2026-01-15-human-rabies.md
    # -> https://epialert.weiqi.kids/Extractor/us_cdc_mmwr/case_series/2026/2026-01-15-human-rabies
    REL_PATH="${file#$PROJECT_ROOT/docs/}"
    REL_PATH="${REL_PATH%.md}"
    CANONICAL_URL="${SITE_URL}/${REL_PATH}"

    # Extract year and filename for breadcrumb
    YEAR=$(basename "$(dirname "$file")")
    FILENAME=$(basename "$file" .md)

    # Generate word count from content (approximate)
    WORD_COUNT=$(sed -n '/^## 摘要/,/^---$/p' "$file" | wc -w | tr -d ' ')

    # Escape special characters for JSON
    TITLE_ESCAPED=$(echo "$TITLE" | sed 's/"/\\"/g')

    # Create temporary file with new frontmatter
    TEMP_FILE="${file}.tmp"

    # Extract existing frontmatter and content
    awk '
    BEGIN { in_frontmatter=0; frontmatter_count=0; }
    /^---$/ {
        frontmatter_count++;
        if (frontmatter_count == 1) {
            in_frontmatter=1;
            print;
            next;
        } else if (frontmatter_count == 2) {
            in_frontmatter=0;
            # Insert SEO frontmatter here
            print "seo:";
            print "  json_ld:";
            print "    - \"@type\": WebPage";
            print "      \"@id\": \"'"$CANONICAL_URL"'#webpage\"";
            print "      url: \"'"$CANONICAL_URL"'\"";
            print "      name: \"'"$TITLE_ESCAPED"'\"";
            print "      inLanguage: zh-TW";
            print "      isPartOf:";
            print "        \"@id\": \"'"$SITE_URL"'#website\"";
            print "      datePublished: \"'"$DATE"'\"";
            print "      dateModified: \"'"$DATE"'\"";
            print "      speakable:";
            print "        \"@type\": SpeakableSpecification";
            print "        cssSelector:";
            print "          - .article-summary";
            print "          - .speakable-content";
            print "          - .key-takeaway";
            print "          - .key-answer";
            print "          - .expert-quote";
            print "          - .actionable-steps li";
            print "          - .faq-answer-content";
            print "    - \"@type\": Article";
            print "      \"@id\": \"'"$CANONICAL_URL"'#article\"";
            print "      headline: \"'"$TITLE_ESCAPED"'\"";
            print "      datePublished: \"'"$DATE"'\"";
            print "      dateModified: \"'"$DATE"'\"";
            print "      author:";
            print "        \"@id\": \"'"$PERSON_ID"'\"";
            print "      publisher:";
            print "        \"@id\": \"'"$ORG_ID"'\"";
            print "      mainEntityOfPage:";
            print "        \"@id\": \"'"$CANONICAL_URL"'#webpage\"";
            print "      inLanguage: zh-TW";
            print "      isAccessibleForFree: true";
            print "      isPartOf:";
            print "        \"@type\": WebSite";
            print "        \"@id\": \"'"$SITE_URL"'#website\"";
            print "        name: EpiAlert 疫情快訊";
            print "        potentialAction:";
            print "          \"@type\": SearchAction";
            print "          target: \"'"$SITE_URL"'/search?q={search_term}\"";
            print "          query-input: required name=search_term";
            print "    - \"@type\": Person";
            print "      \"@id\": \"'"$PERSON_ID"'\"";
            print "      name: EpiAlert AI 編輯";
            print "      url: \"'"$SITE_URL"'/about\"";
            print "      worksFor:";
            print "        \"@id\": \"'"$ORG_ID"'\"";
            print "      knowsAbout:";
            print "        - 傳染病監測";
            print "        - 公共衛生";
            print "        - 疫情分析";
            print "        - 流行病學";
            print "    - \"@type\": Organization";
            print "      \"@id\": \"'"$ORG_ID"'\"";
            print "      name: EpiAlert 疫情快訊";
            print "      url: \"'"$SITE_URL"'\"";
            print "      logo:";
            print "        \"@type\": ImageObject";
            print "        url: \"'"$SITE_URL"'/assets/images/logo.png\"";
            print "        width: 600";
            print "        height: 60";
            print "    - \"@type\": BreadcrumbList";
            print "      itemListElement:";
            print "        - \"@type\": ListItem";
            print "          position: 1";
            print "          name: 首頁";
            print "          item: \"'"$SITE_URL"'\"";
            print "        - \"@type\": ListItem";
            print "          position: 2";
            print "          name: US CDC MMWR";
            print "          item: \"'"$SITE_URL"'/Extractor/us_cdc_mmwr\"";
            print "        - \"@type\": ListItem";
            print "          position: 3";
            print "          name: Case Series";
            print "          item: \"'"$SITE_URL"'/Extractor/us_cdc_mmwr/case_series\"";
            print "        - \"@type\": ListItem";
            print "          position: 4";
            print "          name: \"'"$YEAR"'\"";
            print "          item: \"'"$SITE_URL"'/Extractor/us_cdc_mmwr/case_series/'"$YEAR"'\"";
            print "  ymyl:";
            print "    lastReviewed: \"'"$DATE"'\"";
            print "    reviewedBy: EpiAlert AI 編輯";
            print "    medicalDisclaimer: \"'"$YMYL_DISCLAIMER"'\"";
            print;
            next;
        }
    }
    in_frontmatter { print; next; }
    !in_frontmatter && frontmatter_count >= 2 { print; }
    ' "$file" > "$TEMP_FILE"

    # Replace original file
    mv "$TEMP_FILE" "$file"

    PROCESSED=$((PROCESSED + 1))
    echo "Processed: $file"
done

echo ""
echo "===== SEO Frontmatter Addition Complete ====="
echo "Total files processed: $PROCESSED"
