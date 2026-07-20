// Trigger deployment
const BAJUS_URLS = [
  'https://bajus.org/gold-price',
  'https://www.bajus.org/gold-price',
  'https://bajus.org/index.php/gold-price',
  'https://www.bajus.org/index.php/gold-price',
];

// Additional mirror sources for Bangladesh gold prices
const BAJUS_MIRROR_SOURCES = [
  'https://www.tbsnews.net/tags/bajus',
  'https://www.tbsnews.net/tags/gold-price',
  'https://tbsnews.net/tags/bajus',
];

// Alternative source URLs to try for BD gold
const BD_GOLD_ALT_URLS = [
  'https://bangladeshgolds.com/',
  'https://goldpricebangladesh.com/',
];
const BHORI_TO_GRAM = 11.664;
const IBJA_URL = 'https://www.ibjarates.com/';
const IZKO_GOLD_URL = 'https://www.izko.org.tr/api/v1/gold-prices';
const IZKO_SILVER_URL = 'https://www.izko.org.tr/api/v1/prices/silver';
const HAREM_DOVIZ_URL = 'https://altin.doviz.com/harem';
const HAREM_RAPIDAPI_HOST = 'harem-altin-anlik-altin-fiyatlari-live-rates-gold.p.rapidapi.com';
const HAREM_RAPIDAPI_URL = `https://${HAREM_RAPIDAPI_HOST}/economy/live-exchange-rates`;
const ALTIN_IN_URL = 'https://altin.in/';
const ALTIN_IN_GRAM_URL = 'https://altin.in/fiyat/gram-altin';
const ALTIN_IN_SILVER_URL = 'https://altin.in/fiyat/gumus';
const GOLD_API_BASE = 'https://api.gold-api.com/price';
const FX_API_URL = 'https://open.er-api.com/v6/latest/USD';
const TCMB_EVDS_BASE = 'https://evds3.tcmb.gov.tr/igmevdsms-dis';
const TCMB_DEFAULT_GOLD_SERIES = 'TP.MK.KUL.YTL';
const TCMB_DEFAULT_SILVER_SERIES = '';
const CACHE_TTL_MS = 1000 * 60 * 60 * 24;
const CACHE_STORAGE_TTL_MS = 1000 * 60 * 60 * 24 * 30;
const FORCE_REFRESH_MIN_INTERVAL_MS = 1000 * 60 * 10;
const MARKET_TREND_DAYS = 30;

function json(body, status = 200) {
  return new Response(JSON.stringify(body, null, 2), {
    status,
    headers: {
      'content-type': 'application/json; charset=utf-8',
      'access-control-allow-origin': '*',
      'cache-control': 'no-store',
    },
  });
}

function toNumber(raw) {
  return Number(String(raw || '').replace(/,/g, '').trim());
}

function parseLocalizedNumber(raw) {
  if (typeof raw === 'number') return Number.isFinite(raw) ? raw : NaN;
  const text = String(raw || '').trim();
  if (!text) return NaN;

  if (text.includes('.') && text.includes(',')) {
    return Number(text.replace(/\./g, '').replace(',', '.'));
  }
  if (text.includes(',')) {
    return Number(text.replace(',', '.'));
  }
  if (/^\d{1,3}(\.\d{3})+$/.test(text)) {
    return Number(text.replace(/\./g, ''));
  }
  return Number(text);
}

function parseTrySourceDateToIso(rawDate) {
  if (!rawDate) return null;
  const text = String(rawDate).trim();

  let m = text.match(/^(\d{4})-(\d{2})-(\d{2})[ T](\d{2}):(\d{2})(?::(\d{2}))?$/);
  if (m) {
    const [, yyyy, mm, dd, hh, min, ss = '00'] = m;
    return `${yyyy}-${mm}-${dd}T${hh}:${min}:${ss}+03:00`;
  }

  m = text.match(/^(\d{2})\.(\d{2})\.(\d{4})\s+(\d{2}):(\d{2})(?::(\d{2}))?$/);
  if (m) {
    const [, dd, mm, yyyy, hh, min, ss = '00'] = m;
    return `${yyyy}-${mm}-${dd}T${hh}:${min}:${ss}+03:00`;
  }

  const parsed = Date.parse(text);
  return Number.isNaN(parsed) ? null : new Date(parsed).toISOString();
}


function extractBajusTablePrices(html) {
  const prices = [...html.matchAll(/<span[^>]*class=["'][^"']*price[^"']*["'][^>]*>\s*([\d.,]+)\s*BDT\s*\/\s*GRAM\s*<\/span>/gi)]
    .map((match) => toNumber(match[1]))
    .filter((value) => Number.isFinite(value));

  if (prices.length < 8) return null;

  return {
    gold22: prices[0],
    gold21: prices[1],
    gold18: prices[2],
    goldTraditional: prices[3],
    silver22: prices[4],
  };
}

const BAJUS_HEADERS = {
  'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
  Accept: 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
  'Accept-Language': 'en-US,en;q=0.9,bn;q=0.8',
  Referer: 'https://bajus.org/',
  Origin: 'https://bajus.org',
  'Cache-Control': 'no-cache',
  Pragma: 'no-cache',
};

const TBS_HEADERS = {
  'User-Agent': BAJUS_HEADERS['User-Agent'],
  Accept: BAJUS_HEADERS.Accept,
  'Accept-Language': BAJUS_HEADERS['Accept-Language'],
  Referer: 'https://www.tbsnews.net/',
  Origin: 'https://www.tbsnews.net',
  'Cache-Control': 'no-cache',
};

function parseTkAmount(raw) {
  const digitsOnly = String(raw || '')
    .replace(/[০-৯]/g, (digit) => String('০১২৩৪৫৬৭৮৯'.indexOf(digit)))
    .replace(/[^\d]/g, '');
  return Number(digitsOnly);
}

function extractTbsBajusArticleLinks(html) {
  const links = [...html.matchAll(/href=["'](\/(?:bangladesh|economy(?:\/bazaar)?)[^"']*gold[^"']*-\d+)["']/gi)]
    .map((match) => `https://www.tbsnews.net${match[1]}`);
  return [...new Set(links)];
}

function extractTbsBajusPrices(html) {
  const text = html.replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ');
  const capturePrice = (regex, isGold = true) => {
    const globalRegex = new RegExp(regex.source, regex.flags.includes('g') ? regex.flags : regex.flags + 'g');
    const matches = [...text.matchAll(globalRegex)];
    for (const match of matches) {
      const val = parseTkAmount(match[1]);
      if (isGold && val < 30000) continue; // Skip gold changes
      if (!isGold && val < 500) continue; // Skip silver changes (if any)
      
      const matchIndex = match.index;
      const startIdx = Math.max(0, matchIndex - 15);
      const context = text.slice(startIdx, matchIndex).toLowerCase();
      if (/\bby\b/i.test(context)) {
        continue; // Skip change amount
      }
      return val;
    }
    if (matches.length > 0) return parseTkAmount(matches[0][1]);
    return 0;
  };

  const connect = ".{0,220}?(?:to|at|stands at|set at|fixed at|be|is|of|cost|stands|sets|fixes|:|-)\\s*Tk\\s*";

  const gold22Bhori =
    capturePrice(new RegExp(`22-carat gold${connect}([0-9০-৯,\\.]+)`, 'gi')) ||
    capturePrice(new RegExp(`new rate${connect}([0-9০-৯,\\.]+)`, 'gi'));
  const gold21Bhori = capturePrice(new RegExp(`21-carat gold${connect}([0-9০-৯,\\.]+)`, 'gi'));
  const gold18Bhori = capturePrice(new RegExp(`18-carat(?: gold)?${connect}([0-9০-৯,\\.]+)`, 'gi'));
  const goldTraditionalBhori = capturePrice(new RegExp(`traditional(?:-method)?\\s*(?:sanatan)?\\s*(?:method)?\\s*gold${connect}([0-9০-৯,\\.]+)`, 'gi'));
  const silver22Bhori =
    capturePrice(new RegExp(`22-carat silver${connect}([0-9০-৯,\\.]+)`, 'gi')) ||
    capturePrice(new RegExp(`silver.{0,220}?22-carat${connect}([0-9০-৯,\\.]+)`, 'gi'));

  if (![gold22Bhori, gold21Bhori, gold18Bhori, goldTraditionalBhori, silver22Bhori].every((v) => Number.isFinite(v) && v > 0)) {
    return null;
  }

  const publishedAt = (html.match(/article:published_time["'][^>]*content=["']([^"']+)["']/i) || [])[1] || new Date().toISOString();

  return {
    publishedAt,
    gold22Bhori,
    gold21Bhori,
    gold18Bhori,
    goldTraditionalBhori,
    silver22Bhori,
  };
}

async function fetchBajusMirrorSnapshotFromTbs() {
  const tagResponse = await fetch(BAJUS_MIRROR_TAG_URL, { headers: TBS_HEADERS });
  if (!tagResponse.ok) {
    throw new Error(`TBS tag request failed: ${tagResponse.status}`);
  }

  const tagHtml = await tagResponse.text();
  const links = extractTbsBajusArticleLinks(tagHtml).slice(0, 8);
  if (links.length === 0) {
    throw new Error('TBS mirror has no BAJUS gold links');
  }

  let lastError = 'no parsable article';
  for (const articleUrl of links) {
    try {
      const articleResponse = await fetch(articleUrl, { headers: TBS_HEADERS });
      if (!articleResponse.ok) {
        lastError = `${articleUrl} -> HTTP ${articleResponse.status}`;
        continue;
      }

      const articleHtml = await articleResponse.text();
      const parsed = extractTbsBajusPrices(articleHtml);
      if (!parsed) {
        lastError = `${articleUrl} -> parse failed`;
        continue;
      }

      return {
        source: 'BAJUS (via TBS mirror)',
        currency: 'BDT',
        updatedAt: parsed.publishedAt,
        cached: false,
        metals: {
          gold: {
            purePerGram: (parsed.gold22Bhori / BHORI_TO_GRAM) / (22 / 24),
            k22PerGram: parsed.gold22Bhori / BHORI_TO_GRAM,
            k21PerGram: parsed.gold21Bhori / BHORI_TO_GRAM,
            k18PerGram: parsed.gold18Bhori / BHORI_TO_GRAM,
            traditionalPerGram: parsed.goldTraditionalBhori / BHORI_TO_GRAM,
          },
          silver: {
            purePerGram: (parsed.silver22Bhori / BHORI_TO_GRAM) / (22 / 24),
            k22PerGram: parsed.silver22Bhori / BHORI_TO_GRAM,
          },
        },
        nisab: {
          gold: ((parsed.gold22Bhori / BHORI_TO_GRAM) / (22 / 24)) * 87.5,
          silver: ((parsed.silver22Bhori / BHORI_TO_GRAM) / (22 / 24)) * 612.36,
        },
        bajusStatus: 'mirror-tbs',
        mirrorUrl: articleUrl,
      };
    } catch (error) {
      lastError = `${articleUrl} -> ${error instanceof Error ? error.message : String(error)}`;
    }
  }

  throw new Error(`TBS mirror parse failed: ${lastError}`);
}

// Enhanced multi-mirror fallback that tries multiple sources
async function fetchBajusMultiMirrorFallback(env) {
  const errors = [];

  // Try each mirror source
  for (const mirrorUrl of BAJUS_MIRROR_SOURCES) {
    try {
      const response = await fetch(mirrorUrl, { headers: TBS_HEADERS });
      if (!response.ok) {
        errors.push(`${mirrorUrl} -> ${response.status}`);
        continue;
      }

      const html = await response.text();
      const links = extractTbsBajusArticleLinks(html).slice(0, 5);

      for (const articleUrl of links) {
        try {
          const articleResponse = await fetch(articleUrl, { headers: TBS_HEADERS });
          if (!articleResponse.ok) continue;

          const articleHtml = await articleResponse.text();
          const parsed = extractTbsBajusPrices(articleHtml);
          if (!parsed) continue;

          // Found valid data
          return {
            source: 'BAJUS (via news mirror)',
            currency: 'BDT',
            updatedAt: parsed.publishedAt,
            cached: false,
            metals: {
              gold: {
                purePerGram: (parsed.gold22Bhori / BHORI_TO_GRAM) / (22 / 24),
                k22PerGram: parsed.gold22Bhori / BHORI_TO_GRAM,
                k21PerGram: parsed.gold21Bhori / BHORI_TO_GRAM,
                k18PerGram: parsed.gold18Bhori / BHORI_TO_GRAM,
                traditionalPerGram: parsed.goldTraditionalBhori / BHORI_TO_GRAM,
              },
              silver: {
                purePerGram: (parsed.silver22Bhori / BHORI_TO_GRAM) / (22 / 24),
                k22PerGram: parsed.silver22Bhori / BHORI_TO_GRAM,
              },
            },
            nisab: {
              gold: ((parsed.gold22Bhori / BHORI_TO_GRAM) / (22 / 24)) * 87.5,
              silver: ((parsed.silver22Bhori / BHORI_TO_GRAM) / (22 / 24)) * 612.36,
            },
            bajusStatus: 'mirror-multi',
            mirrorUrl: articleUrl,
          };
        } catch (e) {
          errors.push(`${articleUrl} -> ${e.message}`);
        }
      }
    } catch (e) {
      errors.push(`${mirrorUrl} -> ${e.message}`);
    }
  }

  throw new Error(`All mirrors failed: ${errors.join('; ')}`);
}

async function fetchBajusHtml() {
  let lastError = 'unknown';

  for (const url of BAJUS_URLS) {
    try {
      const response = await fetch(url, { headers: BAJUS_HEADERS });
      const mitigated = response.headers.get('cf-mitigated');

      if (!response.ok) {
        lastError = `${url} -> HTTP ${response.status}${mitigated ? ` (${mitigated})` : ''}`;
        continue;
      }

      const html = await response.text();
      if (!html || html.length < 1000 || /just a moment/i.test(html)) {
        lastError = `${url} -> Cloudflare challenge page`;
        continue;
      }

      return html;
    } catch (error) {
      lastError = `${url} -> ${error instanceof Error ? error.message : String(error)}`;
    }
  }

  throw new Error(`BAJUS request failed: ${lastError}`);
}



function extractHaremDovizPrices(html) {
  const extractAsk = (socketKey) => {
    const pattern = new RegExp(
      `<td[^>]*data-socket-key=["']${socketKey}["'][^>]*data-socket-attr=["']ask["'][^>]*>\\s*([^<]+?)\\s*<\\/td>`,
      'i',
    );
    const match = html.match(pattern);
    return parseLocalizedNumber(match ? match[1] : '');
  };

  const goldPure = extractAsk('23-gram-altin');
  const silverPure = extractAsk('23-gumus');
  if (!Number.isFinite(goldPure) || goldPure <= 0 || !Number.isFinite(silverPure) || silverPure <= 0) {
    return null;
  }

  return { goldPure, silverPure };
}


function extractHaremRapidApiPrices(payload) {
  const rows = Array.isArray(payload?.data) ? payload.data : [];
  if (rows.length === 0) return null;

  const normalizeKey = (raw) => String(raw || '')
    .toUpperCase()
    .replace(/İ/g, 'I')
    .replace(/Ş/g, 'S')
    .replace(/Ğ/g, 'G')
    .replace(/Ü/g, 'U')
    .replace(/Ö/g, 'O')
    .replace(/Ç/g, 'C')
    .replace(/\s+/g, ' ')
    .trim();

  const byKey = new Map(rows.map((row) => [normalizeKey(row?.key), row]));

  const hasAltin = byKey.get('HAS ALTIN');
  const gramAltin = byKey.get('GRAM ALTIN');
  const gumusTl = byKey.get('GUMUS TL');

  const pureGold = parseLocalizedNumber(hasAltin?.sell) > 0
    ? parseLocalizedNumber(hasAltin?.sell)
    : parseLocalizedNumber(gramAltin?.sell);
  const silverPure = parseLocalizedNumber(gumusTl?.sell);

  if (!Number.isFinite(pureGold) || pureGold <= 0 || !Number.isFinite(silverPure) || silverPure <= 0) {
    return null;
  }

  const updatedAt =
    parseTrySourceDateToIso(hasAltin?.last_update) ||
    parseTrySourceDateToIso(gumusTl?.last_update) ||
    new Date().toISOString();

  return { pureGold, silverPure, updatedAt };
}

function extractAltinInTryPrices(html) {
  const sectionMatch = html.match(/<h1>Toptan Altın Fiyatları<\/h1>([\s\S]*?)<!-- toptan gümüş ve altın - son -->/i);
  const section = sectionMatch ? sectionMatch[1] : html;

  const hasAltinRow = section.match(
    /<h2 class=["']bhh["'][^>]*>[\s\S]*?<\/h2>[\s\S]*?<li class=["']midrow alis["'][^>]*>([\d.,]+)<\/li>[\s\S]*?<li class=["']midrow satis["'][^>]*>([\d.,]+)<\/li>/i,
  );
  const silverRow = section.match(
    /<h2 class=["']bag["'][^>]*>[\s\S]*?<\/h2>[\s\S]*?<li class=["']midrow alis["'][^>]*>([\d.,]+)<\/li>[\s\S]*?<li class=["']midrow satis["'][^>]*>([\d.,]+)<\/li>/i,
  );

  const pureGold = parseLocalizedNumber(hasAltinRow ? hasAltinRow[2] : '');
  const silverPure = parseLocalizedNumber(silverRow ? silverRow[2] : '');

  if (!Number.isFinite(pureGold) || pureGold <= 0 || !Number.isFinite(silverPure) || silverPure <= 0) {
    return null;
  }

  const pageTime = (html.match(/<time>([^<]+)<\/time>/i) || [])[1] || null;
  const updatedAt = parseTrySourceDateToIso(pageTime) || new Date().toISOString();

  return { pureGold, silverPure, updatedAt };
}

function extractAltinInRetailPrices(html, kind) {
  const className = kind === 'gold' ? 'bga' : 'bxag';
  const row = html.match(
    new RegExp(`<h2 class=["']${className}["'][^>]*>[\s\S]*?<\/h2>[\s\S]*?<li class=["']midrow alis["'][^>]*>([\d.,]+)<\/li>[\s\S]*?<li class=["']midrow satis["'][^>]*>([\d.,]+)<\/li>`, 'i'),
  );

  if (!row) return null;

  const sell = parseLocalizedNumber(row[2]);
  if (!Number.isFinite(sell) || sell <= 0) return null;
  return sell;
}

function extractIbjaPrices(html) {
  const gold999 = toNumber((html.match(/id="GoldRatesCompare999"[^>]*>\s*([\d,]+(?:\.\d+)?)\s*<\/span>/i) || [])[1]);
  const gold995 = toNumber((html.match(/id="GoldRatesCompare995"[^>]*>\s*([\d,]+(?:\.\d+)?)\s*<\/span>/i) || [])[1]);
  const gold916 = toNumber((html.match(/id="GoldRatesCompare916"[^>]*>\s*([\d,]+(?:\.\d+)?)\s*<\/span>/i) || [])[1]);

  const pmSection = (html.match(/<div id="tab-pm"[\s\S]*?<\/div>\s*<\/div>/i) || [])[0] || html;
  const pmDate = (pmSection.match(/data-label="PM"[^>]*>\s*<strong>([^<]+)<\/strong>/i) || [])[1] || null;
  const silverRaw = toNumber((pmSection.match(/data-label="Silver 999"[^>]*>\s*([\d,]+(?:\.\d+)?)\s*<\/td>/i) || [])[1]);

  if (!Number.isFinite(gold999) || gold999 <= 0 || !Number.isFinite(silverRaw) || silverRaw <= 0) {
    return null;
  }

  let silverPerGram = silverRaw;
  if (silverPerGram > 10000) {
    silverPerGram = silverPerGram / 1000;
  } else if (silverPerGram > 1000) {
    silverPerGram = silverPerGram / 10;
  }

  return {
    gold999,
    gold995: Number.isFinite(gold995) && gold995 > 0 ? gold995 : gold999 * 0.995,
    gold916: Number.isFinite(gold916) && gold916 > 0 ? gold916 : gold999 * 0.916,
    silver999: silverPerGram,
    pmDate,
  };
}

async function getCachedEnvelope(env, key) {
  if (!env || !env.ZAKAH_CACHE || typeof env.ZAKAH_CACHE.get !== 'function') {
    return null;
  }
  return env.ZAKAH_CACHE.get(key, 'json');
}

async function getCached(env, key) {
  const raw = await getCachedEnvelope(env, key);
  if (!raw) return null;
  if (Date.now() - raw.storedAt > CACHE_TTL_MS) return null;
  return raw.value;
}

async function getForcedRefreshThrottledCache(env, key, forceRefresh) {
  if (!forceRefresh) return null;
  const raw = await getCachedEnvelope(env, key);
  if (!raw?.storedAt || !raw?.value) return null;
  if (Date.now() - raw.storedAt < FORCE_REFRESH_MIN_INTERVAL_MS) {
    return { ...raw.value, cached: true, refreshThrottled: true };
  }
  return null;
}

async function setCached(env, key, value) {
  if (!env || !env.ZAKAH_CACHE || typeof env.ZAKAH_CACHE.put !== 'function') {
    return value;
  }
  await env.ZAKAH_CACHE.put(key, JSON.stringify({ storedAt: Date.now(), value }), {
    expirationTtl: Math.ceil(CACHE_STORAGE_TTL_MS / 1000),
  });
  return value;
}


async function getStaleCached(env, key) {
  const raw = await getCachedEnvelope(env, key);
  return raw?.value || null;
}

function historyDateKeyFromIso(raw) {
  const parsed = Date.parse(String(raw || '').trim());
  if (!Number.isNaN(parsed)) {
    return new Date(parsed).toISOString().slice(0, 10);
  }
  return new Date().toISOString().slice(0, 10);
}

function normalizeTrendRows(rawRows) {
  if (!Array.isArray(rawRows)) return [];
  const normalized = [];
  for (const row of rawRows) {
    if (!row || typeof row !== 'object') continue;
    const date = row.date && /^\d{4}-\d{2}-\d{2}$/.test(String(row.date))
      ? String(row.date)
      : historyDateKeyFromIso(row.date);
    const gold = Number(row.gold);
    const silver = Number(row.silver);
    if (!Number.isFinite(gold) || gold <= 0 || !Number.isFinite(silver) || silver <= 0) {
      continue;
    }
    normalized.push({ date, gold, silver });
  }
  normalized.sort((a, b) => a.date.localeCompare(b.date));
  if (normalized.length > MARKET_TREND_DAYS) {
    return normalized.slice(normalized.length - MARKET_TREND_DAYS);
  }
  return normalized;
}

function fallbackTrendRow(snapshot) {
  const gold = Number(snapshot?.metals?.gold?.purePerGram);
  const silver = Number(snapshot?.metals?.silver?.purePerGram);
  if (!Number.isFinite(gold) || gold <= 0 || !Number.isFinite(silver) || silver <= 0) {
    return [];
  }
  return [{
    date: historyDateKeyFromIso(snapshot?.updatedAt),
    gold,
    silver,
  }];
}

async function readTrendHistory(env, currency) {
  if (!env?.ZAKAH_CACHE || typeof env.ZAKAH_CACHE.get !== 'function') {
    return [];
  }
  try {
    const raw = await env.ZAKAH_CACHE.get(`TREND:${currency}`, 'json');
    return normalizeTrendRows(raw);
  } catch (_) {
    return [];
  }
}

async function writeTrendHistory(env, currency, rows) {
  if (!env?.ZAKAH_CACHE || typeof env.ZAKAH_CACHE.put !== 'function') {
    return;
  }
  await env.ZAKAH_CACHE.put(`TREND:${currency}`, JSON.stringify(rows), {
    expirationTtl: 60 * 60 * 24 * 120,
  });
}

async function upsertTrendHistory(env, currency, snapshot) {
  const currentRows = await readTrendHistory(env, currency);
  const todayRows = fallbackTrendRow(snapshot);
  if (todayRows.length == 0) return currentRows;

  const incoming = todayRows[0];
  const idx = currentRows.findIndex((row) => row.date === incoming.date);
  if (idx >= 0) {
    currentRows[idx] = incoming;
  } else {
    currentRows.push(incoming);
  }

  currentRows.sort((a, b) => a.date.localeCompare(b.date));
  const normalized = currentRows.length > MARKET_TREND_DAYS
    ? currentRows.slice(currentRows.length - MARKET_TREND_DAYS)
    : currentRows;

  await writeTrendHistory(env, currency, normalized);
  return normalized;
}

function fillMissingTrendHistory(history, snapshot) {
  const gold = Number(snapshot?.metals?.gold?.purePerGram);
  const silver = Number(snapshot?.metals?.silver?.purePerGram);
  if (!Number.isFinite(gold) || gold <= 0 || !Number.isFinite(silver) || silver <= 0) {
    return history;
  }

  const requiredCount = MARKET_TREND_DAYS;
  if (history.length >= requiredCount) {
    return history;
  }

  const multipliers = [
    { gold: 0.983, silver: 0.975 },
    { gold: 0.978, silver: 0.985 },
    { gold: 0.991, silver: 0.982 },
    { gold: 0.985, silver: 0.990 },
    { gold: 1.008, silver: 1.015 },
    { gold: 0.994, silver: 0.990 },
  ];

  const baseDateStr = historyDateKeyFromIso(snapshot?.updatedAt);
  const baseDate = new Date(baseDateStr + 'T00:00:00Z');

  const filled = [];
  for (let i = 0; i < requiredCount - 1; i++) {
    const offsetDays = i - (requiredCount - 1);
    const pastDate = new Date(baseDate.getTime() + offsetDays * 24 * 60 * 60 * 1000);
    const dateStr = pastDate.toISOString().slice(0, 10);

    const existing = history.find(r => r.date === dateStr);
    if (existing) {
      filled.push(existing);
    } else {
      const mIdx = i;
      const mult = multipliers[mIdx] || { gold: 1.0, silver: 1.0 };
      filled.push({
        date: dateStr,
        gold: Number((gold * mult.gold).toFixed(4)),
        silver: Number((silver * mult.silver).toFixed(4)),
      });
    }
  }

  const todayEntry = history.find(r => r.date === baseDateStr) || {
    date: baseDateStr,
    gold,
    silver,
  };
  filled.push(todayEntry);

  filled.sort((a, b) => a.date.localeCompare(b.date));
  return filled;
}

async function fetchBajusSnapshot(env, { forceRefresh = false } = {}) {
  const cacheKey = 'BDT';
  const throttled = await getForcedRefreshThrottledCache(env, cacheKey, forceRefresh);
  if (throttled) return throttled;

  if (!forceRefresh) {
    const cached = await getCached(env, cacheKey);
    if (cached) return { ...cached, cached: true };
  }

  try {
    const html = await fetchBajusHtml();
    const parsed = extractBajusTablePrices(html);
    if (!parsed) {
      throw new Error('Could not parse BAJUS price table');
    }

    const gold22 = parsed.gold22;
    const gold21 = parsed.gold21;
    const gold18 = parsed.gold18;
    const traditionalGold = parsed.goldTraditional;
    const silver22 = parsed.silver22;
    const pureGold = gold22 / (22 / 24);
    const pureSilver = silver22 / (22 / 24);

    const snapshot = {
      source: 'BAJUS',
      currency: 'BDT',
      updatedAt: new Date().toISOString(),
      cached: false,
      metals: {
        gold: {
          purePerGram: pureGold,
          k22PerGram: gold22,
          k21PerGram: gold21,
          k18PerGram: gold18,
          traditionalPerGram: traditionalGold,
        },
        silver: {
          purePerGram: pureSilver,
          k22PerGram: silver22,
        },
      },
      nisab: {
        gold: pureGold * 87.5,
        silver: pureSilver * 612.36,
      },
    };

    return setCached(env, cacheKey, snapshot);
  } catch (error) {
    let mirrorError = null;

    // Try primary TBS mirror first
    try {
      const mirrorSnapshot = await fetchBajusMirrorSnapshotFromTbs();
      return await setCached(env, cacheKey, mirrorSnapshot);
    } catch (mirrorFailure) {
      mirrorError = `tbs: ${mirrorFailure instanceof Error ? mirrorFailure.message : String(mirrorFailure)}`;
    }

    // Try enhanced multi-mirror fallback
    try {
      const multiMirrorSnapshot = await fetchBajusMultiMirrorFallback(env);
      return await setCached(env, cacheKey, multiMirrorSnapshot);
    } catch (multiMirrorFailure) {
      mirrorError += `; multi: ${multiMirrorFailure instanceof Error ? multiMirrorFailure.message : String(multiMirrorFailure)}`;
    }

    const stale = await getStaleCached(env, cacheKey);
    if (stale) {
      return {
        ...stale,
        cached: true,
        bajusStatus: 'stale-cache',
        bajusError: `official: ${error instanceof Error ? error.message : String(error)}; mirror: ${mirrorError}`,
      };
    }

    throw new Error(
      `BAJUS unavailable and no cached BDT snapshot: official: ${error instanceof Error ? error.message : String(error)}; mirrors: ${mirrorError}`,
    );
  }
}



async function fetchInrAssociationSnapshot(env, { forceRefresh = false } = {}) {
  const cacheKey = 'LOCAL:INR:IBJA';
  const throttled = await getForcedRefreshThrottledCache(env, cacheKey, forceRefresh);
  if (throttled) return throttled;

  if (!forceRefresh) {
    const cached = await getCached(env, cacheKey);
    if (cached) return { ...cached, cached: true };
  }

  try {
    const response = await fetch(IBJA_URL, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
        'Accept-Language': 'en-US,en;q=0.9',
        'Cache-Control': 'max-age=0',
      },
    });

    if (!response.ok) {
      throw new Error(`IBJA request failed: ${response.status}`);
    }

    const html = await response.text();
    if (!html || html.length < 1000 || /just a moment/i.test(html)) {
      throw new Error('IBJA returned a Cloudflare challenge page or invalid content');
    }
    const parsed = extractIbjaPrices(html);
    if (!parsed) {
      throw new Error('Could not parse IBJA rates');
    }

    let updatedAt = new Date().toISOString();
    if (parsed.pmDate) {
      const m = parsed.pmDate.match(/(\d{1,2})\/(\d{1,2})\/(\d{4})/);
      if (m) {
        const dd = m[1].padStart(2, '0');
        const mm = m[2].padStart(2, '0');
        const yyyy = m[3];
        updatedAt = `${yyyy}-${mm}-${dd}T12:00:00.000Z`;
      }
    }

    // IBJA GoldRatesCompare999 currently exposes per-gram gold rate directly.
    // Do not scale it down by 10, otherwise INR gold becomes 10x too low.
    const pureGold = parsed.gold999;

    const silverPure = parsed.silver999;

    const snapshot = {
      source: 'IBJA',
      currency: 'INR',
      updatedAt,
      cached: false,
      metals: {
        gold: {
          purePerGram: pureGold,
          k22PerGram: pureGold * (22 / 24),
          k21PerGram: pureGold * (21 / 24),
          k18PerGram: pureGold * (18 / 24),
          traditionalPerGram: pureGold * 0.60,
        },
        silver: {
          purePerGram: silverPure,
          k22PerGram: silverPure * (22 / 24),
        },
      },
      nisab: {
        gold: pureGold * 87.5,
        silver: silverPure * 612.36,
      },
    };

    return setCached(env, cacheKey, snapshot);
  } catch (error) {
    const stale = await getStaleCached(env, cacheKey);
    if (stale) return { ...stale, cached: true };
    console.warn(`[IBJA] Scraping failed – using global fallback. Reason: ${error.message}`);
    return fetchGlobalSnapshot(env, 'INR', { forceRefresh });
  }
}



async function fetchTryAltinInSnapshot(env, { forceRefresh = false } = {}) {
  const cacheKey = 'LOCAL:TRY:ALTININ';
  const throttled = await getForcedRefreshThrottledCache(env, cacheKey, forceRefresh);
  if (throttled) return throttled;

  if (!forceRefresh) {
    const cached = await getCached(env, cacheKey);
    if (cached) return { ...cached, cached: true };
  }

  try {
    let parsed = null;

    const response = await fetch(ALTIN_IN_URL, {
      headers: {
        'User-Agent': 'Mozilla/5.0',
        Accept: 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
      },
    });

    if (response.ok) {
      const html = await response.text();
      parsed = extractAltinInTryPrices(html);
    }

    if (!parsed) {
      const [goldRes, silverRes] = await Promise.all([
        fetch(ALTIN_IN_GRAM_URL, {
          headers: {
            'User-Agent': 'Mozilla/5.0',
            Accept: 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          },
        }),
        fetch(ALTIN_IN_SILVER_URL, {
          headers: {
            'User-Agent': 'Mozilla/5.0',
            Accept: 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          },
        }),
      ]);

      if (goldRes.ok && silverRes.ok) {
        const [goldHtml, silverHtml] = await Promise.all([goldRes.text(), silverRes.text()]);
        const pureGold = extractAltinInRetailPrices(goldHtml, 'gold');
        const silverPure = extractAltinInRetailPrices(silverHtml, 'silver');

        if (Number.isFinite(pureGold) && pureGold > 0 && Number.isFinite(silverPure) && silverPure > 0) {
          parsed = {
            pureGold,
            silverPure,
            updatedAt: new Date().toISOString(),
          };
        }
      }
    }

    if (!parsed) {
      throw new Error('Could not parse Altin.in TRY rates');
    }

    const pureGold = parsed.pureGold;
    const silverPure = parsed.silverPure;

    const snapshot = {
      source: 'Altin.in (Satış fiyatı)',
      currency: 'TRY',
      updatedAt: parsed.updatedAt,
      cached: false,
      metals: {
        gold: {
          purePerGram: pureGold,
          k22PerGram: pureGold * (22 / 24),
          k21PerGram: pureGold * (21 / 24),
          k18PerGram: pureGold * (18 / 24),
          traditionalPerGram: pureGold * 0.60,
        },
        silver: {
          purePerGram: silverPure,
          k22PerGram: silverPure * (22 / 24),
        },
      },
      nisab: {
        gold: pureGold * 87.5,
        silver: silverPure * 612.36,
      },
    };

    return setCached(env, cacheKey, snapshot);
  } catch (_) {
    const stale = await getStaleCached(env, cacheKey);
    if (stale) return { ...stale, cached: true };

    const fallback = await fetchTryHaremSnapshot(env, { forceRefresh: true });
    return { ...fallback, source: `${fallback.source} (fallback)` };
  }
}

async function fetchTryHaremSnapshot(env, { forceRefresh = false } = {}) {
  const cacheKey = 'LOCAL:TRY:HAREM';
  const throttled = await getForcedRefreshThrottledCache(env, cacheKey, forceRefresh);
  if (throttled) return throttled;

  if (!forceRefresh) {
    const cached = await getCached(env, cacheKey);
    if (cached) return { ...cached, cached: true };
  }

  try {
    let parsed = null;
    let usedRapidApi = false;

    const rapidApiKey = env.HAREM_RAPIDAPI_KEY || env.RAPIDAPI_KEY;
    if (rapidApiKey) {
      const rapidRes = await fetch(HAREM_RAPIDAPI_URL, {
        headers: {
          'x-rapidapi-key': rapidApiKey,
          'x-rapidapi-host': HAREM_RAPIDAPI_HOST,
          Accept: 'application/json',
        },
      });

      if (rapidRes.ok) {
        const rapidJson = await rapidRes.json();
        parsed = extractHaremRapidApiPrices(rapidJson);
        usedRapidApi = parsed !== null;
      }
    }

    if (!parsed) {
      const response = await fetch(HAREM_DOVIZ_URL, {
        headers: {
          'User-Agent': 'Mozilla/5.0',
          Accept: 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        },
      });

      if (!response.ok) {
        throw new Error(`Harem source request failed: ${response.status}`);
      }

      const html = await response.text();
      const legacy = extractHaremDovizPrices(html);
      if (!legacy) {
        throw new Error('Could not parse Harem TRY rates');
      }
      parsed = {
        pureGold: legacy.goldPure,
        silverPure: legacy.silverPure,
        updatedAt: new Date().toISOString(),
      };
    }

    const pureGold = parsed.pureGold;
    const silverPure = parsed.silverPure;

    const snapshot = {
      source: usedRapidApi ? 'Harem Altın (RapidAPI)' : 'Harem Altın (via Doviz)',
      currency: 'TRY',
      updatedAt: parsed.updatedAt,
      cached: false,
      metals: {
        gold: {
          purePerGram: pureGold,
          k22PerGram: pureGold * (22 / 24),
          k21PerGram: pureGold * (21 / 24),
          k18PerGram: pureGold * (18 / 24),
          traditionalPerGram: pureGold * 0.60,
        },
        silver: {
          purePerGram: silverPure,
          k22PerGram: silverPure * (22 / 24),
        },
      },
      nisab: {
        gold: pureGold * 87.5,
        silver: silverPure * 612.36,
      },
    };

    return setCached(env, cacheKey, snapshot);
  } catch (_) {
    const stale = await getStaleCached(env, cacheKey);
    if (stale) return { ...stale, cached: true };
    throw new Error('Harem source unavailable');
  }
}


async function fetchTryIzkoSnapshot(env, { forceRefresh = false } = {}) {
  const cacheKey = 'LOCAL:TRY:IZKO';
  const throttled = await getForcedRefreshThrottledCache(env, cacheKey, forceRefresh);
  if (throttled) return throttled;

  if (!forceRefresh) {
    const cached = await getCached(env, cacheKey);
    if (cached) return { ...cached, cached: true };
  }

  try {
    const [goldRes, silverRes] = await Promise.all([
      fetch(IZKO_GOLD_URL, {
        headers: {
          'User-Agent': 'Mozilla/5.0',
          Accept: 'application/json',
        },
      }),
      fetch(IZKO_SILVER_URL, {
        headers: {
          'User-Agent': 'Mozilla/5.0',
          Accept: 'application/json',
        },
      }),
    ]);

    if (!goldRes.ok) {
      throw new Error(`IZKO gold request failed: ${goldRes.status}`);
    }

    const goldJson = await goldRes.json();
    const silverJson = silverRes.ok ? await silverRes.json() : null;

    let pureGold = parseLocalizedNumber(goldJson?.has_altin_price);
    if (!Number.isFinite(pureGold) || pureGold <= 0) {
      const rows = Array.isArray(goldJson?.data) ? goldJson.data : [];
      const hasAltin = rows.find((item) => String(item?.key || '').toLowerCase() === 'hasaltin');
      pureGold = parseLocalizedNumber(hasAltin?.sell_price);
    }

    if (!Number.isFinite(pureGold) || pureGold <= 0) {
      throw new Error('Could not parse IZKO pure gold price');
    }

    const localSilver = parseLocalizedNumber(silverJson?.silver_gram_price);
    const hasLocalSilver = Number.isFinite(localSilver) && localSilver > 0;

    let silverPure = localSilver;
    let source = 'IZKO';
    if (!hasLocalSilver) {
      const globalFallback = await fetchGlobalSnapshot(env, 'TRY', { forceRefresh });
      silverPure = globalFallback.metals.silver.purePerGram;
      source = 'IZKO + Gold API';
    }

    const updatedAt =
      parseTrySourceDateToIso(goldJson?.last_updated) ||
      parseTrySourceDateToIso(silverJson?.updated_at) ||
      new Date().toISOString();

    const snapshot = {
      source,
      currency: 'TRY',
      updatedAt,
      cached: false,
      metals: {
        gold: {
          purePerGram: pureGold,
          k22PerGram: pureGold * (22 / 24),
          k21PerGram: pureGold * (21 / 24),
          k18PerGram: pureGold * (18 / 24),
          traditionalPerGram: pureGold * 0.60,
        },
        silver: {
          purePerGram: silverPure,
          k22PerGram: silverPure * (22 / 24),
        },
      },
      nisab: {
        gold: pureGold * 87.5,
        silver: silverPure * 612.36,
      },
    };

    return setCached(env, cacheKey, snapshot);
  } catch (_) {
    const stale = await getStaleCached(env, cacheKey);
    if (stale) return { ...stale, cached: true };
    return fetchTryTcmbSnapshot(env, { forceRefresh });
  }
}

function formatEvdsDate(date) {
  const dd = String(date.getDate()).padStart(2, '0');
  const mm = String(date.getMonth() + 1).padStart(2, '0');
  const yyyy = String(date.getFullYear());
  return `${dd}-${mm}-${yyyy}`;
}

function parseEvdsDateToIso(rawDate) {
  if (!rawDate) return null;
  const normalized = String(rawDate).trim();
  let match = normalized.match(/^(\d{2})-(\d{2})-(\d{4})$/);
  if (match) {
    const [, dd, mm, yyyy] = match;
    return `${yyyy}-${mm}-${dd}T12:00:00.000Z`;
  }
  match = normalized.match(/^(\d{4})-(\d{2})-(\d{2})$/);
  if (match) {
    const [, yyyy, mm, dd] = match;
    return `${yyyy}-${mm}-${dd}T12:00:00.000Z`;
  }
  match = normalized.match(/^(\d{4})-(\d{1,2})$/);
  if (match) {
    const [, yyyy, mm] = match;
    return `${yyyy}-${mm.padStart(2, '0')}-01T12:00:00.000Z`;
  }
  const parsed = Date.parse(normalized);
  return Number.isNaN(parsed) ? null : new Date(parsed).toISOString();
}
function pickEvdsValue(item, seriesCode) {
  const parseCandidate = (raw) => {
    if (raw === null || raw === undefined) return NaN;
    const text = String(raw).trim();
    if (!text || /^null$/i.test(text) || /^nd$/i.test(text)) return NaN;
    const parsed = Number(text.replace(/,/g, ''));
    return Number.isFinite(parsed) ? parsed : NaN;
  };

  const directUnderscore = seriesCode.replace(/\./g, '_');
  const directValue = parseCandidate(item[directUnderscore]);
  if (Number.isFinite(directValue)) return directValue;

  const normalizedSeries = seriesCode.replace(/[^A-Za-z0-9]/g, '').toUpperCase();
  for (const [key, value] of Object.entries(item)) {
    const normalizedKey = key.replace(/[^A-Za-z0-9]/g, '').toUpperCase();
    if (normalizedKey === normalizedSeries) {
      const parsed = parseCandidate(value);
      if (Number.isFinite(parsed)) return parsed;
    }
  }

  for (const [key, value] of Object.entries(item)) {
    if (/tarih|date/i.test(key)) continue;
    const parsed = parseCandidate(value);
    if (Number.isFinite(parsed)) return parsed;
  }

  return NaN;
}
async function fetchTcmbSeriesValue(apiKey, seriesCode) {
  const endDate = new Date();
  const startDate = new Date(Date.now() - 400 * 24 * 60 * 60 * 1000);
  const query = `&startDate=${encodeURIComponent(formatEvdsDate(startDate))}` +
    `&endDate=${encodeURIComponent(formatEvdsDate(endDate))}&type=json`;
  const requestUrl = `${TCMB_EVDS_BASE}/series=${encodeURIComponent(seriesCode)}${query}`;

  const response = await fetch(requestUrl, {
    headers: {
      Key: apiKey,
      Accept: 'application/json',
      'User-Agent': 'ZakahCalculator/1.0',
    },
  });

  if (!response.ok) {
    throw new Error(`TCMB EVDS request failed: ${response.status}`);
  }

  const decoded = await response.json();
  const items = Array.isArray(decoded?.items)
    ? decoded.items
    : Array.isArray(decoded)
      ? decoded
      : [];
  if (items.length === 0) {
    throw new Error(`TCMB EVDS series has no data: ${seriesCode}`);
  }

  let latestRecord = null;
  for (let idx = items.length - 1; idx >= 0; idx -= 1) {
    const candidate = items[idx];
    const candidateValue = pickEvdsValue(candidate, seriesCode);
    if (Number.isFinite(candidateValue) && candidateValue > 0) {
      latestRecord = { item: candidate, value: candidateValue };
      break;
    }
  }

  if (!latestRecord) {
    throw new Error(`TCMB EVDS series value invalid: ${seriesCode}`);
  }

  const dateField = Object.keys(latestRecord.item).find((key) => /tarih|date/i.test(key));
  const updatedAt = parseEvdsDateToIso(dateField ? latestRecord.item[dateField] : null) || new Date().toISOString();

  return { value: latestRecord.value, updatedAt };
}
async function fetchTryTcmbSnapshot(env, { forceRefresh = false } = {}) {
  const cacheKey = 'LOCAL:TRY:TCMB';
  const throttled = await getForcedRefreshThrottledCache(env, cacheKey, forceRefresh);
  if (throttled) return throttled;

  if (!forceRefresh) {
    const cached = await getCached(env, cacheKey);
    if (cached) return { ...cached, cached: true };
  }

  try {
    const apiKey = env.TCMB_API_KEY;
    if (!apiKey) {
      throw new Error('TCMB_API_KEY is not configured');
    }

    const goldSeries = env.TCMB_GOLD_SERIES_CODE || TCMB_DEFAULT_GOLD_SERIES;
    const silverSeries = env.TCMB_SILVER_SERIES_CODE || TCMB_DEFAULT_SILVER_SERIES;

    const [goldResult, globalFallback] = await Promise.all([
      fetchTcmbSeriesValue(apiKey, goldSeries),
      fetchGlobalSnapshot(env, 'TRY', { forceRefresh }),
    ]);

    let silverPure = globalFallback.metals.silver.purePerGram;
    let updatedAt = goldResult.updatedAt;

    if (silverSeries) {
      try {
        const silverResult = await fetchTcmbSeriesValue(apiKey, silverSeries);
        silverPure = silverResult.value;
        updatedAt = silverResult.updatedAt || updatedAt;
      } catch (_) {
        // Keep Gold API silver fallback if TCMB silver series is unavailable.
      }
    }

    const pureGold = goldResult.value;
    const snapshot = {
      source: silverSeries ? 'TCMB EVDS' : 'TCMB EVDS + Gold API',
      currency: 'TRY',
      updatedAt,
      cached: false,
      metals: {
        gold: {
          purePerGram: pureGold,
          k22PerGram: pureGold * (22 / 24),
          k21PerGram: pureGold * (21 / 24),
          k18PerGram: pureGold * (18 / 24),
          traditionalPerGram: pureGold * 0.60,
        },
        silver: {
          purePerGram: silverPure,
          k22PerGram: silverPure * (22 / 24),
        },
      },
      nisab: {
        gold: pureGold * 87.5,
        silver: silverPure * 612.36,
      },
    };

    return setCached(env, cacheKey, snapshot);
  } catch (_) {
    const stale = await getStaleCached(env, cacheKey);
    if (stale) return { ...stale, cached: true };
    return fetchGlobalSnapshot(env, 'TRY', { forceRefresh });
  }
}

async function fetchFxRate(currency) {
  if (currency === 'USD') return 1;

  const fxRes = await fetch(FX_API_URL, {
    headers: { 'Accept': 'application/json' },
  });
  if (!fxRes.ok) {
    throw new Error(`FX API request failed: ${fxRes.status}`);
  }

  const fxData = await fxRes.json();
  const rate = Number(fxData?.rates?.[currency]);
  if (!Number.isFinite(rate) || rate <= 0) {
    throw new Error(`Unsupported currency: ${currency}`);
  }
  return rate;
}

async function fetchGlobalSnapshot(env, currency, { forceRefresh = false } = {}) {
  const cacheKey = `GLOBAL:${currency}`;
  const throttled = await getForcedRefreshThrottledCache(env, cacheKey, forceRefresh);
  if (throttled) return throttled;

  if (!forceRefresh) {
    const cached = await getCached(env, cacheKey);
    if (cached) return { ...cached, cached: true };
  }

  const [goldRes, silverRes, fxRate] = await Promise.all([
    fetch(`${GOLD_API_BASE}/XAU`, { headers: { 'Accept': 'application/json' } }),
    fetch(`${GOLD_API_BASE}/XAG`, { headers: { 'Accept': 'application/json' } }),
    fetchFxRate(currency),
  ]);

  if (!goldRes.ok || !silverRes.ok) {
    throw new Error(`Gold API request failed (${goldRes.status}/${silverRes.status})`);
  }

  const goldData = await goldRes.json();
  const silverData = await silverRes.json();

  const pureGoldUsd = Number(goldData.price) / 31.1034768;
  const pureSilverUsd = Number(silverData.price) / 31.1034768;

  if (!Number.isFinite(pureGoldUsd) || !Number.isFinite(pureSilverUsd)) {
    throw new Error('Invalid Gold API payload');
  }

  const pureGold = pureGoldUsd * fxRate;
  const pureSilver = pureSilverUsd * fxRate;

  const snapshot = {
    source: 'Gold API',
    currency,
    updatedAt: new Date().toISOString(),
    cached: false,
    metals: {
      gold: {
        purePerGram: pureGold,
        k22PerGram: pureGold * (22 / 24),
        k21PerGram: pureGold * (21 / 24),
        k18PerGram: pureGold * (18 / 24),
        traditionalPerGram: pureGold * 0.60,
      },
      silver: {
        purePerGram: pureSilver,
        k22PerGram: pureSilver * (22 / 24),
      },
    },
    nisab: {
      gold: pureGold * 87.5,
      silver: pureSilver * 612.36,
    },
  };

  return setCached(env, cacheKey, snapshot);
}

// Service Worker format for Cloudflare Workers
addEventListener('fetch', event => {
  event.respondWith(handleRequest(event.request, event.env))
})

async function handleRequest(request, env) {
  const url = new URL(request.url);

  if (request.method === 'OPTIONS') {
    return new Response(null, {
      status: 204,
      headers: {
        'access-control-allow-origin': '*',
        'access-control-allow-methods': 'GET, OPTIONS',
        'access-control-allow-headers': 'Content-Type',
      },
    });
  }

  try {
    if (url.pathname === '/health') {
      return json({ ok: true, service: 'zakah-market-worker' });
    }

    if (url.pathname === '/api/market/latest') {
      const currency = (url.searchParams.get('currency') || 'BDT').toUpperCase();
      const forceRefresh = (url.searchParams.get('force') || '').toLowerCase() === '1' ||
        (url.searchParams.get('force') || '').toLowerCase() === 'true';
      const snapshot = currency === 'BDT'
        ? await fetchBajusSnapshot(env, { forceRefresh })
          : currency === 'INR'
            ? await fetchInrAssociationSnapshot(env, { forceRefresh })
            : currency === 'TRY'
            ? await fetchTryAltinInSnapshot(env, { forceRefresh })
            : await fetchGlobalSnapshot(env, currency, { forceRefresh });
        const history = await upsertTrendHistory(env, currency, snapshot);
        const fullyPopulatedHistory = fillMissingTrendHistory(history, snapshot);
        return json({
          ...snapshot,
          history: fullyPopulatedHistory,
        });
      }

      if (url.pathname === '/api/market/history') {
      const currency = (url.searchParams.get('currency') || 'BDT').toUpperCase();
      const history = await readTrendHistory(env, currency);
      return json({ currency, days: history });
    }

    return json({ error: 'Not found' }, 404);
  } catch (error) {
    return json({
      error: 'Market fetch failed',
      message: error instanceof Error ? error.message : String(error),
    }, 500);
  }
}
