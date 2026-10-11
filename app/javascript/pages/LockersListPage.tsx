import React from 'react';

import LockersTable from '../components/lockers/LockersTable';
import { useTranslation } from '../i18n/I18nContext';
import type { Locker } from '../types/locker';

export interface LockersListPageProps {
  lockers: Locker[];
}

const LockersListPage = ({ lockers }: LockersListPageProps) => {
  const t = useTranslation();

  return (
    <>
      <h1 className="h3 mb-3">{t('lockers.title')}</h1>

      {lockers.length === 0 ? (
        <p className="text-body-secondary">{t('lockers.empty')}</p>
      ) : (
        <LockersTable lockers={lockers} />
      )}
    </>
  );
};

export default LockersListPage;
