#!/usr/bin/env bun
/**
 * Usage:
 *   bun run switch-provider.bun.ts --preset openai --in ./config.base.json --out ./config.json
 *   bun run switch-provider.bun.ts --preset openai-claude --in ./config.base.json --out ./config.json
 *   bun run switch-provider.bun.ts --preset github-copilot-claude --in ./config.base.json --out ./config.json
 *   bun run switch-provider.bun.ts --preset antigravity-gemini --in ./config.base.json --out ./config.json
 *   bun run switch-provider.bun.ts --preset antigravity-claude --in ./config.base.json --out ./config.json
 *
 * Notes:
 * - Keeps `variant` fields as-is.
 * - Overwrites only `model`.
 * - Forces multimodal-looker to gemini-3-flash for every preset.
 *
 * Deps:
 * - jsonc-parser
 */

import {existsSync} from 'node:fs';
import {parse as parseJsonc} from 'jsonc-parser';

type Preset =
    | 'openai'
    | 'openai-claude'
    | 'github-copilot-claude'
    | 'antigravity-gemini'
    | 'antigravity-claude';

type Tier = 'Ultra' | 'High' | 'Fast' | 'Docs' | 'gemini-3-flash';

type AgentConfig = {model: string; variant?: string; [k: string]: unknown};
type RootConfig = {
    agents?: Record<string, AgentConfig>;
    categories?: Record<string, AgentConfig>;
    [k: string]: unknown;
};

// --- tiers (aligned to your recommended doc intent) ---
const AGENT_TIER: Record<string, Tier> = {
    // orchestrators / strategic planners
    sisyphus: 'High',
    prometheus: 'Ultra',
    metis: 'Ultra',

    // strong general
    atlas: 'High',
    oracle: 'High',
    momus: 'High',

    // docs/search/grep style
    librarian: 'Docs',
    explore: 'Fast',

    // multimodal forced
    'multimodal-looker': 'gemini-3-flash',
};

const CATEGORY_TIER: Record<string, Tier> = {
    'visual-engineering': 'Docs',
    ultrabrain: 'Ultra',
    artistry: 'High',
    writing: 'High',
    quick: 'Fast',
    'unspecified-low': 'Fast',
    'unspecified-high': 'High',
};

// --- models by preset ---
const PRESET_MODELS: Record<Preset, Record<Exclude<Tier, 'gemini-3-flash'>, string>> = {
    openai: {
        Ultra: 'openai/gpt-5.1-codex',
        High: 'openai/gpt-5.1-codex',
        Docs: 'openai/gpt-5.1-codex-mini',
        Fast: 'github-copilot/claude-haiku-4.5',
    },
    'openai-claude': {
        Ultra: 'openai/claude-sonnet-4.5',
        High: 'openai/claude-sonnet-4.5',
        Docs: 'openai/gpt-5.2-codex-mini',
        Fast: 'openai/claude-haiku-4.5',
    },
    'github-copilot-claude': {
        Ultra: 'github-copilot/claude-sonnet-4.5',
        High: 'github-copilot/claude-sonnet-4.5',
        Docs: 'github-copilot/claude-haiku-4.5',
        Fast: 'github-copilot/claude-haiku-4.5',
    },
    'antigravity-gemini': {
        Ultra: 'google/antigravity-gemini-3-pro',
        High: 'google/antigravity-gemini-3-pro',
        Docs: 'google/antigravity-gemini-3-flash',
        Fast: 'google/antigravity-gemini-3-flash',
    },
    'antigravity-claude': {
        Ultra: 'google/antigravity-claude-sonnet-4-5',
        High: 'google/antigravity-claude-sonnet-4-5',
        Docs: 'google/antigravity-gemini-3-flash',
        // If antigravity-haiku exists in your stack, swap this:
        // Fast: "google/antigravity-claude-haiku-4-5",
        Fast: 'google/antigravity-gemini-3-flash',
    },
};

const FORCED_MULTIMODAL_MODEL = 'google/gemini-3-flash';

// --- cli ---
function readArg(flag: string): string | undefined {
    const i = Bun.argv.indexOf(flag);
    return i === -1 ? undefined : Bun.argv[i + 1];
}

const preset = readArg('--preset') as Preset | undefined;
const inPath = readArg('--in') ?? './config.base.jsonc';
const outPath = readArg('--out') ?? './config.jsonc';

if (!preset || !(preset in PRESET_MODELS)) {
    console.error(
        `Missing/invalid --preset. Use: openai | openai-claude | github-copilot-claude | antigravity-gemini | antigravity-claude`
    );
    process.exit(1);
}

if (!existsSync(inPath)) {
    console.error(`Input file not found: ${inPath}`);
    process.exit(1);
}

function pickModelForTier(p: Preset, tier: Tier): string {
    if (tier === 'gemini-3-flash') return FORCED_MULTIMODAL_MODEL;
    return PRESET_MODELS[p][tier];
}

function rewriteSection(
    section: Record<string, AgentConfig> | undefined,
    tierMap: Record<string, Tier>,
    p: Preset
): Record<string, AgentConfig> | undefined {
    if (!section) return section;

    const out: Record<string, AgentConfig> = {};
    for (const [name, cfg] of Object.entries(section)) {
        const tier = tierMap[name];
        if (!tier) {
            out[name] = {...cfg};
            continue;
        }
        const nextModel =
            name === 'multimodal-looker' ? FORCED_MULTIMODAL_MODEL : pickModelForTier(p, tier);

        out[name] = {...cfg, model: nextModel};
    }
    return out;
}

// --- main ---
const raw = await Bun.file(inPath).text();
const base = parseJsonc(raw) as RootConfig;

if (!base || typeof base !== 'object') {
    console.error(`Failed to parse JSONC from ${inPath}`);
    process.exit(1);
}

const next: RootConfig = {
    ...base,
    agents: rewriteSection(base.agents, AGENT_TIER, preset),
    categories: rewriteSection(base.categories, CATEGORY_TIER, preset),
};

// NOTE: This outputs valid JSON (no comments). Extension can still be .jsonc if you want.
await Bun.write(outPath, JSON.stringify(next, null, 4) + '\n');
console.log(`✅ Wrote ${outPath} using preset "${preset}" (from ${inPath})`);
