export interface HighlightSearchWord {
  text: string;
  className?: string;
  style?: Record<string, string>;
}

export type HighlightSearchWordInput = string | HighlightSearchWord;

export interface HighlightChunk {
  start: number;
  end: number;
  highlight: boolean;
  className?: string;
  style?: Record<string, string>;
}

function escapeRegExp(text: string): string {
  return text.replace(/[-[\]/{}()*+?.\\^$|]/g, '\\$&');
}

interface RawChunk {
  start: number;
  end: number;
  className?: string;
  style?: Record<string, string>;
}

/** 对每个关键词独立做正则全局匹配，产出所有命中片段（未去重叠）。 */
function findChunks(
  sourceString: string,
  searchWords: HighlightSearchWordInput[],
  caseSensitive: boolean,
  autoEscape: boolean,
): RawChunk[] {
  const chunks: RawChunk[] = [];

  for (const raw of searchWords) {
    const word: HighlightSearchWord = typeof raw === 'string' ? { text: raw } : raw;
    if (!word.text) continue;

    const searchText = autoEscape ? escapeRegExp(word.text) : word.text;
    if (!searchText) continue;

    const regex = new RegExp(searchText, caseSensitive ? 'g' : 'gi');
    let match: RegExpExecArray | null;
    while ((match = regex.exec(sourceString))) {
      chunks.push({
        start: match.index,
        end: match.index + match[0].length,
        className: word.className,
        style: word.style,
      });
      // 零宽匹配保护：防止空匹配导致死循环
      if (match.index === regex.lastIndex) regex.lastIndex++;
    }
  }

  return chunks;
}

/** 按 start 排序后合并重叠/相邻片段，避免同一段文字被重复高亮。 */
function combineChunks(chunks: RawChunk[]): RawChunk[] {
  const sorted = [...chunks].sort((a, b) => a.start - b.start);

  const combined: RawChunk[] = [];
  for (const chunk of sorted) {
    const last = combined[combined.length - 1];
    if (last && chunk.start <= last.end) {
      last.end = Math.max(last.end, chunk.end);
      last.className = last.className || chunk.className;
      last.style = { ...last.style, ...chunk.style };
    } else {
      combined.push({ ...chunk });
    }
  }

  return combined;
}

/** 用非高亮片段补齐间隙，形成覆盖全字符串的连续分段序列。 */
function fillInChunks(highlightChunks: RawChunk[], totalLength: number): HighlightChunk[] {
  const result: HighlightChunk[] = [];

  function append(start: number, end: number, highlight: boolean, className?: string, style?: Record<string, string>) {
    if (end - start <= 0) return;
    result.push({ start, end, highlight, className, style });
  }

  if (highlightChunks.length === 0) {
    append(0, totalLength, false);
    return result;
  }

  let lastIndex = 0;
  for (const chunk of highlightChunks) {
    append(lastIndex, chunk.start, false);
    append(chunk.start, chunk.end, true, chunk.className, chunk.style);
    lastIndex = chunk.end;
  }
  append(lastIndex, totalLength, false);

  return result;
}

/**
 * 把 sourceString 按 searchWords 匹配情况切分为连续、不重叠、覆盖全串的分段序列。
 * 对齐 Semi Highlight 的三段流水线算法（findChunks → combineChunks → fillInChunks），
 * 纯函数、无状态。
 */
export function findHighlightChunks(
  sourceString: string,
  searchWords: HighlightSearchWordInput[],
  caseSensitive: boolean = false,
  autoEscape: boolean = true,
): HighlightChunk[] {
  const rawChunks = findChunks(sourceString, searchWords, caseSensitive, autoEscape);
  const combined = combineChunks(rawChunks);
  return fillInChunks(combined, sourceString.length);
}
