import React from 'react';
import type { ComponentType } from 'react';

import { I18nProvider } from '../i18n/I18nContext';
import type { SharedPageProps } from '../types/page';
import { CsrfProvider } from './CsrfContext';

// Wraps a page so its components can read the props shared by every page
// (see ApplicationController#page_props) without passing them down by hand.
const withProviders = <PageProps extends object>(Page: ComponentType<PageProps>) => {
  const PageWithProviders = ({ translations, csrfToken, ...pageProps }: SharedPageProps & PageProps) => (
    <I18nProvider translations={translations}>
      <CsrfProvider value={csrfToken}>
        <Page {...(pageProps as PageProps)} />
      </CsrfProvider>
    </I18nProvider>
  );

  return PageWithProviders;
};

export default withProviders;
