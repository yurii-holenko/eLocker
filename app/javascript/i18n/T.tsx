import React from 'react';

import { useTranslation } from './I18nContext';
import type { TranslationValues } from './translate';

// A translated text as a component, for places that cannot call the hook,
// such as table column definitions kept outside of components.
const T = ({ id, values }: { id: string; values?: TranslationValues }) => <>{useTranslation()(id, values)}</>;

export default T;
