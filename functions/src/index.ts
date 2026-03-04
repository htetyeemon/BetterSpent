import {onCall, HttpsError} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import {logger} from "firebase-functions";

const geminiApiKey = defineSecret("GEMINI_API_KEY");

const allowedCategories = [
  "Food & Drink",
  "Transport",
  "Shopping",
  "Entertainment",
  "Bills",
  "Grocery",
  "Health",
  "Other",
];

const fallbackModels = [
  "gemini-2.5-flash",
  "gemini-flash-latest",
  "gemini-2.5-flash-lite",
  "gemini-2.0-flash",
  "gemini-2.0-flash-lite",
  "gemini-pro-latest",
];

type GeminiExpense = {
  amount?: number;
  category?: string;
  note?: string;
  date?: string;
};

function toIsoDate(date: Date): string {
  const y = date.getFullYear().toString().padStart(4, "0");
  const m = (date.getMonth() + 1).toString().padStart(2, "0");
  const d = date.getDate().toString().padStart(2, "0");
  return `${y}-${m}-${d}`;
}

function stripCodeFences(text: string): string {
  if (!text.startsWith("```")) return text;
  return text
    .replace(/^```[a-zA-Z]*\n?/, "")
    .replace(/\n?```$/, "")
    .trim();
}

function normalizeCategory(raw: string | undefined): string {
  if (!raw) return "Other";
  const found = allowedCategories.find(
    (category) => category.toLowerCase() === raw.trim().toLowerCase(),
  );
  return found ?? "Other";
}

function parseDateOrToday(raw: string | undefined, todayIso: string): string {
  if (!raw) return todayIso;
  const parsed = new Date(raw);
  if (Number.isNaN(parsed.getTime())) return todayIso;
  return toIsoDate(parsed);
}

function parseIsoDate(raw: string | undefined): Date | null {
  if (!raw || !/^\d{4}-\d{2}-\d{2}$/.test(raw)) return null;
  const parsed = new Date(`${raw}T00:00:00`);
  if (Number.isNaN(parsed.getTime())) return null;
  return parsed;
}

export const parseExpense = onCall(
  {
    region: "us-central1",
    secrets: [geminiApiKey],
    enforceAppCheck: false,
    timeoutSeconds: 30,
  },
  async (request) => {
    const input = String(request.data?.input ?? "").trim();
    if (!input) {
      return {expenses: []};
    }

    const clientLocalDateRaw = String(request.data?.clientLocalDate ?? "").trim();
    const baseDate = parseIsoDate(clientLocalDateRaw) ?? new Date();
    const todayIso = toIsoDate(baseDate);
    const yesterdayDate = new Date(baseDate);
    yesterdayDate.setDate(yesterdayDate.getDate() - 1);
    const yesterdayIso = toIsoDate(yesterdayDate);
    const prompt = `Extract all expenses from this user input: "${input}"
Today is ${todayIso}.

Return JSON only with this exact shape:
{"expenses":[{"amount": number, "category": string, "note": string, "date": "YYYY-MM-DD"}]}

Rules:
- amount must be a positive number.
- category must be one of: ${allowedCategories.join(", ")}.
- note should be a short clean note, without currency symbols.
- Correct minor spelling mistakes in note text when obvious (example: "javket" -> "jacket").
- date must be inferred from the user's text and returned as YYYY-MM-DD.
- if user says "today", use ${todayIso}.
- if user says "yesterday", use ${yesterdayIso}.
- if no date clue is present, default to ${todayIso}.
- If uncertain, use category "Other".
- Include every expense mentioned by the user.
- Do not invent expenses that are not explicitly in the input.
- If the input is unclear, random text, or missing a real expense, return {"expenses":[]}.
- If no expense exists, return {"expenses":[]}.`;

    const key = geminiApiKey.value();
    if (!key) {
      throw new HttpsError("failed-precondition", "Missing GEMINI_API_KEY secret.");
    }

    let lastError: string | null = null;

    for (const model of fallbackModels) {
      const url =
        "https://generativelanguage.googleapis.com/v1/models/" +
        `${model}:generateContent?key=${encodeURIComponent(key)}`;

      const response = await fetch(url, {
        method: "POST",
        headers: {"Content-Type": "application/json"},
        body: JSON.stringify({
          contents: [{parts: [{text: prompt}]}],
          generationConfig: {
            temperature: 0.1,
          },
        }),
      });

      if (!response.ok) {
        const errText = await response.text();
        lastError = `status=${response.status} model=${model} body=${errText}`;
        logger.error("Gemini request failed", {
          model,
          status: response.status,
          body: errText,
        });
        continue;
      }

      const body = (await response.json()) as {
        candidates?: Array<{content?: {parts?: Array<{text?: string}>}}>;
      };

      const text = body.candidates?.[0]?.content?.parts?.[0]?.text?.trim();
      if (!text) {
        return {expenses: []};
      }

      let parsed: unknown;
      try {
        parsed = JSON.parse(stripCodeFences(text));
      } catch (e) {
        logger.error("Failed to parse Gemini JSON", e);
        return {expenses: []};
      }

      const rawExpenses =
        typeof parsed === "object" &&
        parsed !== null &&
        Array.isArray((parsed as {expenses?: unknown[]}).expenses)
          ? (parsed as {expenses: unknown[]}).expenses
          : [];

      const sanitized = rawExpenses
        .filter((item): item is GeminiExpense => typeof item === "object" && item !== null)
        .map((item) => {
          const amount = Number(item.amount);
          return {
            amount,
            category: normalizeCategory(item.category),
            note: String(item.note ?? "").trim(),
            date: parseDateOrToday(item.date, todayIso),
          };
        })
        .filter((item) => Number.isFinite(item.amount) && item.amount > 0)
        .map((item) => ({
          ...item,
          note: item.note || input,
        }));

      return {expenses: sanitized};
    }

    throw new HttpsError("internal", `Gemini request failed: ${lastError ?? "unknown"}`);
  },
);
