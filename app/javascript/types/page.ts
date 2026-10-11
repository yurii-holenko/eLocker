import type { Translations } from '../i18n/translate';

// Props every page receives from ApplicationController#page_props.
export interface SharedPageProps {
  translations: Translations;
  csrfToken: string;
}
