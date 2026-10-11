// The `react` subtree of config/locales/*.yml.
export interface Translations {
  [key: string]: string | Translations;
}

export type TranslationValues = Record<string, string | number>;

// Looks up a dotted key ("lockers.columns.name") in the translations passed
// from Rails and fills in `%{placeholders}`, mirroring Rails' I18n.t.
const translate = (translations: Translations, key: string, values: TranslationValues = {}): string => {
  const text = key
    .split('.')
    .reduce<string | Translations | undefined>(
      (node, part) => (typeof node === 'object' ? node[part] : undefined),
      translations,
    );

  if (typeof text !== 'string') return key;

  return text.replace(/%\{(\w+)\}/g, (_match, name: string) => String(values[name] ?? ''));
};

export default translate;
