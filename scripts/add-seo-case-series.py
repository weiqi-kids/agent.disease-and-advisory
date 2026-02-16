#!/usr/bin/env python3
"""
Add SEO frontmatter to us_cdc_mmwr/case_series extraction results.
Adds JSON-LD Schema and YMYL frontmatter to all case_series/*.md files.
"""

import os
import re
import sys
from pathlib import Path
from datetime import datetime

# Base configuration
SITE_URL = "https://epialert.weiqi.kids"
ORG_ID = f"{SITE_URL}#organization"
PERSON_ID = f"{SITE_URL}/about#person"
YMYL_DISCLAIMER = "本站內容由 AI 自動彙整自 WHO、CDC 等官方來源，僅供參考，不構成醫療建議。如有健康疑慮，請諮詢專業醫療人員。"

# Speakable CSS selectors (from seo/CLAUDE.md)
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
    """Extract frontmatter and body from markdown content."""
    if not content.startswith('---\n'):
        return {}, content

    # Find the second --- delimiter
    match = re.match(r'^---\n(.*?)\n---\n(.*)$', content, re.DOTALL)
    if not match:
        return {}, content

    frontmatter_text = match.group(1)
    body = match.group(2)

    # Parse frontmatter as key-value pairs
    frontmatter = {}
    for line in frontmatter_text.split('\n'):
        if ':' in line:
            key, value = line.split(':', 1)
            key = key.strip()
            value = value.strip().strip('"')
            frontmatter[key] = value

    return frontmatter, body


def build_seo_frontmatter(file_path, frontmatter):
    """Build SEO frontmatter structure."""
    title = frontmatter.get('title', '')
    date = frontmatter.get('date', '')
    source_url = frontmatter.get('source_url', '')

    # Generate canonical URL from file path
    # Remove project root and .md extension
    project_root = Path(__file__).parent.parent / 'docs'
    rel_path = file_path.relative_to(project_root).with_suffix('')
    canonical_url = f"{SITE_URL}/{rel_path}"

    # Extract year for breadcrumb
    year = file_path.parent.name

    # Build SEO structure
    seo = {
        'json_ld': [
            {
                '@type': 'WebPage',
                '@id': f'{canonical_url}#webpage',
                'url': canonical_url,
                'name': title,
                'inLanguage': 'zh-TW',
                'isPartOf': {'@id': f'{SITE_URL}#website'},
                'datePublished': date,
                'dateModified': date,
                'speakable': {
                    '@type': 'SpeakableSpecification',
                    'cssSelector': SPEAKABLE_SELECTORS
                }
            },
            {
                '@type': 'Article',
                '@id': f'{canonical_url}#article',
                'headline': title,
                'datePublished': date,
                'dateModified': date,
                'author': {'@id': PERSON_ID},
                'publisher': {'@id': ORG_ID},
                'mainEntityOfPage': {'@id': f'{canonical_url}#webpage'},
                'inLanguage': 'zh-TW',
                'isAccessibleForFree': True,
                'isPartOf': {
                    '@type': 'WebSite',
                    '@id': f'{SITE_URL}#website',
                    'name': 'EpiAlert 疫情快訊',
                    'potentialAction': {
                        '@type': 'SearchAction',
                        'target': f'{SITE_URL}/search?q={{search_term}}',
                        'query-input': 'required name=search_term'
                    }
                }
            },
            {
                '@type': 'Person',
                '@id': PERSON_ID,
                'name': 'EpiAlert AI 編輯',
                'url': f'{SITE_URL}/about',
                'worksFor': {'@id': ORG_ID},
                'knowsAbout': ['傳染病監測', '公共衛生', '疫情分析', '流行病學']
            },
            {
                '@type': 'Organization',
                '@id': ORG_ID,
                'name': 'EpiAlert 疫情快訊',
                'url': SITE_URL,
                'logo': {
                    '@type': 'ImageObject',
                    'url': f'{SITE_URL}/assets/images/logo.png',
                    'width': 600,
                    'height': 60
                }
            },
            {
                '@type': 'BreadcrumbList',
                'itemListElement': [
                    {'@type': 'ListItem', 'position': 1, 'name': '首頁', 'item': SITE_URL},
                    {'@type': 'ListItem', 'position': 2, 'name': 'US CDC MMWR', 'item': f'{SITE_URL}/Extractor/us_cdc_mmwr'},
                    {'@type': 'ListItem', 'position': 3, 'name': 'Case Series', 'item': f'{SITE_URL}/Extractor/us_cdc_mmwr/case_series'},
                    {'@type': 'ListItem', 'position': 4, 'name': year, 'item': f'{SITE_URL}/Extractor/us_cdc_mmwr/case_series/{year}'}
                ]
            }
        ],
        'ymyl': {
            'lastReviewed': date,
            'reviewedBy': 'EpiAlert AI 編輯',
            'medicalDisclaimer': YMYL_DISCLAIMER
        }
    }

    return seo


def format_yaml_value(value, indent=0):
    """Format a Python value as YAML."""
    prefix = '  ' * indent

    if isinstance(value, dict):
        lines = []
        for k, v in value.items():
            if isinstance(v, (dict, list)):
                lines.append(f'{prefix}{k}:')
                lines.append(format_yaml_value(v, indent + 1))
            else:
                # Quote strings that contain special characters
                if isinstance(v, str) and (':' in v or '#' in v or v.startswith('@')):
                    lines.append(f'{prefix}{k}: "{v}"')
                else:
                    lines.append(f'{prefix}{k}: {v}')
        return '\n'.join(lines)

    elif isinstance(value, list):
        lines = []
        for item in value:
            if isinstance(item, (dict, list)):
                lines.append(f'{prefix}-')
                item_yaml = format_yaml_value(item, indent + 1)
                # Add proper indentation for dict items under list
                if isinstance(item, dict):
                    item_lines = item_yaml.split('\n')
                    lines.append('  ' + item_lines[0])
                    for line in item_lines[1:]:
                        lines.append('  ' + line)
                else:
                    lines.extend(item_yaml.split('\n'))
            else:
                if isinstance(item, str) and (':' in item or '#' in item or item.startswith('@')):
                    lines.append(f'{prefix}- "{item}"')
                else:
                    lines.append(f'{prefix}- {item}')
        return '\n'.join(lines)

    else:
        return str(value)


def process_file(file_path):
    """Process a single markdown file to add SEO frontmatter."""
    # Read file
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Check if already has SEO
    if '\nseo:\n' in content or '\nseo:' in content[:500]:
        return False, "Already has SEO"

    # Extract frontmatter and body
    frontmatter, body = extract_frontmatter(content)

    if not frontmatter:
        return False, "No frontmatter found"

    # Build SEO structure
    seo = build_seo_frontmatter(file_path, frontmatter)

    # Reconstruct frontmatter with SEO added
    new_frontmatter_lines = ['---']

    # Add existing frontmatter
    for key, value in frontmatter.items():
        if '"' in value:
            new_frontmatter_lines.append(f'{key}: \'{value}\'')
        else:
            new_frontmatter_lines.append(f'{key}: "{value}"')

    # Add SEO section
    new_frontmatter_lines.append('seo:')
    new_frontmatter_lines.append('  json_ld:')

    for schema in seo['json_ld']:
        new_frontmatter_lines.append('    -')
        for key, value in schema.items():
            if key == '@type' or key == '@id':
                new_frontmatter_lines.append(f'      "{key}": "{value}"')
            elif isinstance(value, dict):
                new_frontmatter_lines.append(f'      {key}:')
                dict_yaml = format_yaml_value(value, 4)
                new_frontmatter_lines.append(dict_yaml)
            elif isinstance(value, list):
                new_frontmatter_lines.append(f'      {key}:')
                for item in value:
                    if isinstance(item, str):
                        new_frontmatter_lines.append(f'        - {item}')
                    else:
                        new_frontmatter_lines.append(f'        -')
                        dict_yaml = format_yaml_value(item, 5)
                        for line in dict_yaml.split('\n'):
                            new_frontmatter_lines.append(line)
            elif isinstance(value, bool):
                new_frontmatter_lines.append(f'      {key}: {str(value).lower()}')
            else:
                if ':' in str(value) or '#' in str(value):
                    new_frontmatter_lines.append(f'      {key}: "{value}"')
                else:
                    new_frontmatter_lines.append(f'      {key}: {value}')

    # Add YMYL section
    new_frontmatter_lines.append('  ymyl:')
    for key, value in seo['ymyl'].items():
        if isinstance(value, str) and ('，' in value or '。' in value):
            new_frontmatter_lines.append(f'    {key}: "{value}"')
        else:
            new_frontmatter_lines.append(f'    {key}: {value}')

    new_frontmatter_lines.append('---')

    # Reconstruct file
    new_content = '\n'.join(new_frontmatter_lines) + '\n' + body

    # Write back
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(new_content)

    return True, "Processed"


def main():
    """Main execution."""
    project_root = Path(__file__).parent.parent
    case_series_dir = project_root / 'docs' / 'Extractor' / 'us_cdc_mmwr' / 'case_series'

    if not case_series_dir.exists():
        print(f"Error: Directory not found: {case_series_dir}")
        sys.exit(1)

    # Find all .md files in 2025/ and 2026/, excluding index.md
    files_to_process = []
    for year_dir in [case_series_dir / '2025', case_series_dir / '2026']:
        if year_dir.exists():
            for md_file in year_dir.glob('*.md'):
                if md_file.name != 'index.md':
                    files_to_process.append(md_file)

    files_to_process.sort()

    print(f"Found {len(files_to_process)} files to process")
    print()

    processed = 0
    skipped = 0
    errors = 0

    for file_path in files_to_process:
        try:
            success, message = process_file(file_path)
            if success:
                processed += 1
                print(f"✓ {file_path.name}")
            else:
                skipped += 1
                print(f"- {file_path.name}: {message}")
        except Exception as e:
            errors += 1
            print(f"✗ {file_path.name}: {e}")

    print()
    print("=" * 60)
    print(f"SEO Frontmatter Addition Complete")
    print(f"Total files found: {len(files_to_process)}")
    print(f"Processed: {processed}")
    print(f"Skipped: {skipped}")
    print(f"Errors: {errors}")
    print("=" * 60)


if __name__ == '__main__':
    main()
