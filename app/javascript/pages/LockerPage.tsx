import React from 'react';

import ActionsTable from '../components/actions/ActionsTable';
import LockerDetails from '../components/lockers/LockerDetails';
import { useTranslation } from '../i18n/I18nContext';
import type { LockerDetails as LockerDetailsData } from '../types/locker';
import type { LockerActionRecord } from '../types/lockerAction';
import type { PaginationData } from '../types/pagination';

export interface LockerPageProps {
  locker: LockerDetailsData;
  actions: LockerActionRecord[];
  pagination: PaginationData;
  lockersPath: string;
}

const LockerPage = ({ locker, actions, pagination, lockersPath }: LockerPageProps) => {
  const t = useTranslation();

  return (
    <>
      <a href={lockersPath} className="small">
        ← {t('lockers.back')}
      </a>
      <h1 className="h3 mt-2 mb-3">{locker.name}</h1>

      <LockerDetails locker={locker} />

      <h2 className="h5 mb-3">{t('history.title')}</h2>
      <ActionsTable actions={actions} pagination={pagination} />
    </>
  );
};

export default LockerPage;
