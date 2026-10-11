import { createContext, useContext } from 'react';

// Rails' authenticity token, needed by every form that POSTs.
const CsrfContext = createContext('');

export const CsrfProvider = CsrfContext.Provider;
export const useCsrfToken = (): string => useContext(CsrfContext);
