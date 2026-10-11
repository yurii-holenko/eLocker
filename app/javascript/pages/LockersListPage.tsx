import React from 'react';

import LockersFilter from '../components/lockers/LockersFilter';
import type { LockersFilterData } from '../components/lockers/LockersFilter';
import LockersTable from '../components/lockers/LockersTable';
import { useTranslation } from '../i18n/I18nContext';
import type { Locker } from '../types/locker';
import type { PaginationData } from '../types/pagination';

export interface LockersListPageProps {
  lockers: Locker[];
  pagination: PaginationData;
  filter: LockersFilterData;
}

const LockersListPage = ({ lockers, pagination, filter }: LockersListPageProps) => {
  const t = useTranslation();

  return (
    <>
      <div className="d-flex align-items-baseline justify-content-between mb-3">
        <h1 className="h3 mb-0">{t('lockers.title')}</h1>
        <span className="text-body-secondary small">{t('lockers.found', { count: pagination.totalCount })}</span>
      </div>

      <LockersFilter filter={filter} />
      <LockersTable lockers={lockers} pagination={pagination} />
    </>
  );
};

export default LockersListPage;
