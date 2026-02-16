#!/usr/bin/env python3
"""
Add SEO frontmatter to ECDC CDTR extraction results.
This script processes all MD files in the ecdc_cdtr layer and adds comprehensive SEO metadata.
"""

import os
import re
import yaml
from pathlib import Path
from datetime import datetime

# EpiAlert fixed values
SITE_URL = "https://epialert.weiqi.kids"
SITE_NAME = "EpiAlert 疫情快訊"

# Speakable selectors (all 7 required)
SPEAKABLE_SELECTORS = [
    ".article-summary",
    ".speakable-content",
    ".key-takeaway",
    ".key-answer",
    ".expert-quote",
    ".actionable-steps li",
    ".faq-answer-content"
]

def extract_frontmatter(content):
    """Extract frontmatter and content from markdown file."""
    match = re.match(r'^---\n(.*?)\n---\n(.*)$', content, re.DOTALL)
    if not match:
        return None, content

    frontmatter_str = match.group(1)
    body = match.group(2)

    # Parse YAML frontmatter
    frontmatter = yaml.safe_load(frontmatter_str)
    return frontmatter, body

def extract_first_paragraph(body):
    """Extract the first paragraph after ## 摘要 as description."""
    # Look for ## 摘要 section
    match = re.search(r'## 摘要\s*\n\s*\n(.+?)(?:\n\n|$)', body, re.DOTALL)
    if match:
        # Get first paragraph and clean it
        desc = match.group(1).strip()
        # Remove any markdown formatting
        desc = re.sub(r'\[([^\]]+)\]\([^\)]+\)', r'\1', desc)  # Remove links
        desc = re.sub(r'[*_`]', '', desc)  # Remove emphasis markers
        return desc
    return ""

def generate_keywords(title, diseases, regions, category):
    """Generate keywords from title, diseases, regions, and category."""
    keywords = []

    # Extract key terms from title
    title_words = re.findall(r'\b\w{4,}\b', title.lower())
    keywords.extend(title_words[:5])  # Take first 5 significant words

    # Add diseases
    if diseases:
        keywords.extend([d.lower() for d in diseases[:3]])

    # Add regions
    if regions:
        keywords.extend([r.lower() for r in regions[:2]])

    # Add category
    keywords.append(category)
    keywords.append("ECDC")

    return ", ".join(keywords[:10])  # Limit to 10 keywords

def generate_seo_frontmatter(frontmatter, body, file_path):
    """Generate SEO frontmatter based on existing metadata."""
    title = frontmatter.get('title', '')
    source_url = frontmatter.get('source_url', '')
    date = str(frontmatter.get('date', ''))
    category = frontmatter.get('category', 'guidance')
    diseases = frontmatter.get('diseases', [])
    regions = frontmatter.get('regions', [])

    # Generate description from first paragraph
    description = extract_first_paragraph(body)
    if not description:
        description = title  # Fallback to title

    # Generate URL path from file path
    rel_path = file_path.replace('/Users/lightman/weiqi.kids/agent.disease-and-advisory/docs/', '')
    rel_path = rel_path.replace('.md', '')
    page_url = f"{SITE_URL}/{rel_path}"

    # Generate keywords
    keywords = generate_keywords(title, diseases, regions, category)

    # Capitalize category for breadcrumb
    category_display = category.replace('_', ' ').title()

    seo = {
        'json_ld': [
            # WebPage Schema
            {
                '@type': 'WebPage',
                '@id': f'{page_url}#webpage',
                'url': page_url,
                'name': title,
                'description': description,
                'inLanguage': 'zh-TW',
                'isPartOf': {
                    '@id': f'{SITE_URL}#website'
                },
                'datePublished': date,
                'dateModified': date,
                'speakable': {
                    '@type': 'SpeakableSpecification',
                    'cssSelector': SPEAKABLE_SELECTORS
                }
            },
            # Article Schema
            {
                '@type': 'Article',
                '@id': f'{page_url}#article',
                'headline': title,
                'description': description,
                'author': {
                    '@id': f'{SITE_URL}/about#person'
                },
                'publisher': {
                    '@id': f'{SITE_URL}#organization'
                },
                'datePublished': date,
                'dateModified': date,
                'mainEntityOfPage': {
                    '@id': f'{page_url}#webpage'
                },
                'articleSection': category,
                'keywords': keywords,
                'inLanguage': 'zh-TW',
                'isAccessibleForFree': True,
                'isPartOf': {
                    '@type': 'WebSite',
                    '@id': f'{SITE_URL}#website',
                    'name': SITE_NAME,
                    'potentialAction': {
                        '@type': 'SearchAction',
                        'target': f'{SITE_URL}/search?q={{search_term}}',
                        'query-input': 'required name=search_term'
                    }
                }
            },
            # Person Schema
            {
                '@type': 'Person',
                '@id': f'{SITE_URL}/about#person',
                'name': 'EpiAlert AI 編輯',
                'url': f'{SITE_URL}/about',
                'description': 'AI 驅動的疫情資訊彙整系統，自動收集並分析來自 WHO、CDC 等官方來源的傳染病情報',
                'worksFor': {
                    '@id': f'{SITE_URL}#organization'
                },
                'knowsAbout': [
                    '傳染病監測',
                    '公共衛生',
                    '疫情分析',
                    '流行病學'
                ],
                'hasCredential': [
                    {
                        '@type': 'EducationalOccupationalCredential',
                        'name': 'AI 輔助醫療資訊系統',
                        'credentialCategory': 'Automated Health Intelligence System'
                    }
                ],
                'sameAs': [
                    'https://github.com/anthropics/claude-code'
                ]
            },
            # Organization Schema
            {
                '@type': 'Organization',
                '@id': f'{SITE_URL}#organization',
                'name': SITE_NAME,
                'url': SITE_URL,
                'logo': {
                    '@type': 'ImageObject',
                    'url': f'{SITE_URL}/assets/images/logo.png',
                    'width': 600,
                    'height': 60
                },
                'description': '全球傳染病情報自動收集與分析系統',
                'sameAs': [
                    'https://github.com/anthropics/claude-code'
                ],
                'contactPoint': {
                    '@type': 'ContactPoint',
                    'contactType': 'technical support',
                    'url': 'https://github.com/anthropics/claude-code/issues'
                }
            },
            # BreadcrumbList Schema
            {
                '@type': 'BreadcrumbList',
                'itemListElement': [
                    {
                        '@type': 'ListItem',
                        'position': 1,
                        'name': '首頁',
                        'item': SITE_URL
                    },
                    {
                        '@type': 'ListItem',
                        'position': 2,
                        'name': 'ECDC CDTR',
                        'item': f'{SITE_URL}/Extractor/ecdc_cdtr'
                    },
                    {
                        '@type': 'ListItem',
                        'position': 3,
                        'name': category_display,
                        'item': f'{SITE_URL}/Extractor/ecdc_cdtr/{category}'
                    },
                    {
                        '@type': 'ListItem',
                        'position': 4,
                        'name': title,
                        'item': page_url
                    }
                ]
            }
        ],
        'ymyl': {
            'lastReviewed': date,
            'reviewedBy': 'EpiAlert AI 編輯',
            'medicalDisclaimer': '本站內容由 AI 自動彙整自 WHO、CDC 等官方來源,僅供參考,不構成醫療建議。如有健康疑慮,請諮詢專業醫療人員。'
        }
    }

    return seo

def process_file(file_path):
    """Process a single markdown file to add SEO frontmatter."""
    print(f"Processing: {file_path}")

    # Read file
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Extract frontmatter and body
    frontmatter, body = extract_frontmatter(content)

    if frontmatter is None:
        print(f"  ⚠️  No frontmatter found, skipping")
        return False

    # Check if SEO already exists
    if 'seo' in frontmatter:
        print(f"  ℹ️  SEO frontmatter already exists, skipping")
        return False

    # Generate SEO frontmatter
    seo = generate_seo_frontmatter(frontmatter, body, file_path)

    # Add SEO to frontmatter
    frontmatter['seo'] = seo

    # Reconstruct file
    # Use custom YAML dumper to preserve formatting
    frontmatter_str = yaml.dump(frontmatter,
                                allow_unicode=True,
                                default_flow_style=False,
                                sort_keys=False,
                                width=1000)

    new_content = f"---\n{frontmatter_str}---\n{body}"

    # Write back
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(new_content)

    print(f"  ✅ SEO frontmatter added")
    return True

def main():
    """Process all ecdc_cdtr markdown files."""
    base_dir = Path("/Users/lightman/weiqi.kids/agent.disease-and-advisory/docs/Extractor/ecdc_cdtr")

    # Find all MD files except index.md
    md_files = []
    for root, dirs, files in os.walk(base_dir):
        for file in files:
            if file.endswith('.md') and file != 'index.md':
                md_files.append(os.path.join(root, file))

    md_files.sort()

    print(f"Found {len(md_files)} files to process\n")

    processed = 0
    skipped = 0

    for file_path in md_files:
        if process_file(file_path):
            processed += 1
        else:
            skipped += 1
        print()

    print(f"\n{'='*60}")
    print(f"Summary:")
    print(f"  ✅ Processed: {processed}")
    print(f"  ⏭️  Skipped: {skipped}")
    print(f"  📊 Total: {len(md_files)}")
    print(f"{'='*60}")

if __name__ == '__main__':
    main()
