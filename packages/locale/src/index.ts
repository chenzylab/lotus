import zhCN from './zh-CN.js';
import enUS from './en-US.js';

export type { LocaleShape, FormLocale, InputLocale, InputNumberLocale, TextAreaLocale, SelectLocale } from './types.js';
export { zhCN, enUS };

export const locales = {
  'zh-CN': zhCN,
  'en-US': enUS,
} as const;

export type LocaleCode = keyof typeof locales;
