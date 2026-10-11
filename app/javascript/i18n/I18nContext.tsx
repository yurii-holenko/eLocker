import React, { createContext, useCallback, useContext } from 'react';
import type { ReactNode } from 'react';

import translate from './translate';
import type { Translations, TranslationValues } from './translate';

export type Translate = (key: string, values?: TranslationValues) => string;

const I18nContext = createContext<Translations>({});

interface I18nProviderProps {
  translations: Translations;
  children: ReactNode;
}

export const I18nProvider = ({ translations, children }: I18nProviderProps) => (
  <I18nContext.Provider value={translations}>{children}</I18nContext.Provider>
);

// const t = useTranslation(); t('lockers.title')
export const useTranslation = (): Translate => {
  const translations = useContext(I18nContext);

  return useCallback((key, values) => translate(translations, key, values), [translations]);
};
